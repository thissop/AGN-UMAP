import tensorflow as tf
from tensorflow.keras.layers import Conv1D, MaxPooling1D, Flatten, Dense, PReLU, Input, Reshape, Layer, Lambda
from tensorflow.keras.models import Model
import tensorflow.keras.backend as K
import numpy as np
from astropy.io import fits
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt
import os
from scipy.ndimage import gaussian_filter1d

def build_encoder(input_shape, latent_dim):
    input_layer = Input(shape=input_shape)

    # Convolutional Layers
    x = Conv1D(filters=128, kernel_size=5, padding='valid', name='conv1')(input_layer)
    x = PReLU(name='prelu1')(x)
    x = MaxPooling1D(pool_size=2, name='maxpool1')(x)

    x = Conv1D(filters=256, kernel_size=11, padding='valid', name='conv2')(x)
    x = PReLU(name='prelu2')(x)
    x = MaxPooling1D(pool_size=2, name='maxpool2')(x)

    x = Conv1D(filters=512, kernel_size=21, padding='valid', name='conv3')(x)
    x = PReLU(name='prelu3')(x)
    x = MaxPooling1D(pool_size=2, name='maxpool3')(x)

    # Flatten the output from Conv layers
    x = Flatten(name='flatten')(x)

    # Fully Connected Layers
    x = Dense(256, name='dense1')(x)
    x = PReLU(name='prelu4')(x)
    x = Dense(128, name='dense2')(x)
    x = PReLU(name='prelu5')(x)
    x = Dense(64, name='dense3')(x)
    x = PReLU(name='prelu6')(x)

    # Latent Space
    latent_space = Dense(latent_dim, name='latent_space')(x)

    return Model(input_layer, latent_space, name='encoder')

def build_decoder(latent_dim, output_dim, rest_range, observed_range, observed_resolution, upsample_factor):
    # Inputs: latent vector and scalar z
    latent_input = Input(shape=(latent_dim,), name='latent_input')
    z_input = Input(shape=(1,), name='z')  # Scalar input for z
    
    # Step 1: Fully Connected Layers to generate rest frame representation
    x = Dense(64)(latent_input)
    x = PReLU()(x)    
    x = Dense(256)(x)
    x = PReLU()(x)
    x = Dense(1024)(x)
    x = PReLU()(x)

    # Generate rest frame grid
    min_rest_x, max_rest_x = rest_range
    rest_length = int((max_rest_x - min_rest_x) / observed_resolution * upsample_factor)
    rest_x = tf.linspace(min_rest_x, max_rest_x, rest_length)

    # Upsample Layer 
    x = Dense(rest_length)(x)
    x = PReLU()(x)

    # Define a Lambda layer to handle TensorFlow operations on Keras tensors
    def slice_and_downsample(inputs):
        x, z_input = inputs

        # Compute Boundary Indexes based on rest_x, observed_range, and z_input
        min_rest_obs = observed_range[0] / (1 + z_input)
        max_rest_obs = observed_range[1] / (1 + z_input)

        # Find start and stop indices using TensorFlow operations
        start_index = tf.argmin(tf.abs(rest_x - min_rest_obs))
        stop_index = tf.argmin(tf.abs(rest_x - max_rest_obs))

        # Slice and downsample the tensor
        sliced_x = x[:, start_index:stop_index]

        # Ensure downsampling results in `output_dim` elements
        downsample_factor = tf.cast(tf.shape(sliced_x)[1] / output_dim, tf.int32)
        output = sliced_x[:, ::downsample_factor]

        return output

    # Define the output shape manually
    def compute_output_shape(input_shapes):
        latent_shape, z_shape = input_shapes
        return (latent_shape[0], output_dim)

    # Use Lambda layer to apply the slicing and downsampling
    output = Lambda(slice_and_downsample, output_shape=compute_output_shape)([x, z_input])

    # Reshape the final output to the desired dimensions
    output = Reshape((output_dim, 1))(output)

    return Model([latent_input, z_input], output, name='decoder')
def build_autoencoder(input_shape, latent_dim, z_range, observed_range, observed_resolution, upsample_factor):
    spectra_input = Input(shape=input_shape, name='spectra_input')
    
    # Building the encoder (you would define build_encoder separately)
    encoder = build_encoder(input_shape, latent_dim)
    latent_space = encoder(spectra_input)
    
    # Scalar z input for each iteration
    z_input = Input(shape=(1,), name='z_input')
    
    # Building the decoder, which now takes both latent vector and scalar z

    rest_range = [observed_range[0]/(1+z_range[1]), observed_range[1]/(1+z_range[0])]

    decoder = build_decoder(latent_dim, input_shape[0], rest_range, observed_range, observed_resolution, upsample_factor)
    reconstructed_output = decoder([latent_space, z_input])

    # Define the complete autoencoder model
    return Model(inputs=[spectra_input, z_input], outputs=reconstructed_output, name='autoencoder')

observed_range = [3550, 10400]
observed_resolution = (observed_range[1]-observed_range[0])/1500
z_range = [1.5, 2.2]

autoencoder = build_autoencoder(input_shape=(1500, 1), latent_dim=10, z_range=z_range, observed_range=observed_range, observed_resolution=observed_resolution, upsample_factor=2)

autoencoder.compile(optimizer='adam', loss='mse')
autoencoder.summary()

