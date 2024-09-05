import tensorflow as tf
from tensorflow.keras.layers import Conv1D, MaxPooling1D, Flatten, Dense, PReLU, Input, Reshape, Layer
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

# Custom layer to compute start and stop indices based on z and rest_x
class IndexComputationLayer(Layer):
    def __init__(self, min_rest_x, max_rest_x, **kwargs):
        super(IndexComputationLayer, self).__init__(**kwargs)
        self.min_rest_x = min_rest_x
        self.max_rest_x = max_rest_x

    def call(self, inputs):
        rest_x, z = inputs
        start_index = tf.cast(tf.argmin(tf.abs(rest_x - self.min_rest_x / (1 + z)), axis=0), tf.int32)
        stop_index = tf.cast(tf.argmin(tf.abs(rest_x - self.max_rest_x / (1 + z)), axis=0), tf.int32)
        return start_index, stop_index


def build_decoder(latent_dim, output_dim, min_rest_x, max_rest_x, observed_resolution, upsample_factor):
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
    rest_length = int((max_rest_x - min_rest_x) / observed_resolution * upsample_factor)
    rest_x = tf.linspace(min_rest_x, max_rest_x, rest_length)

    # Compute start and stop indices using the custom layer
    start_index, stop_index = IndexComputationLayer(min_rest_x, max_rest_x)([rest_x, z_input])

    x = Dense(rest_length)(x)
    x = PReLU()(x)

    # Slice and Downsample the tensor
    sliced_x = tf.slice(x, [start_index], [stop_index - start_index])
    output = sliced_x[::upsample_factor]

    # Reshape the final output to the desired dimensions
    output = Reshape((output_dim, 1))(output)

    return Model([latent_input, z_input], output, name='decoder')

def build_autoencoder(input_shape, latent_dim, min_rest_x, max_rest_x, observed_resolution, upsample_factor):
    spectra_input = Input(shape=input_shape, name='spectra_input')
    
    # Building the encoder (you would define build_encoder separately)
    encoder = build_encoder(input_shape, latent_dim)
    latent_space = encoder(spectra_input)
    
    # Scalar z input for each iteration
    z_input = Input(shape=(1,), name='z_input')
    
    # Building the decoder, which now takes both latent vector and scalar z

    decoder = build_decoder(latent_dim, input_shape[0], min_rest_x, max_rest_x, observed_resolution, upsample_factor)
    reconstructed_output = decoder([latent_space, z_input])

    # Define the complete autoencoder model
    return Model(inputs=[spectra_input, z_input], outputs=reconstructed_output, name='autoencoder')

max_observed_x = 10400
min_observed_x = 3550
observed_resolution = (max_observed_x-min_observed_x)/1500
max_z = 2.2
min_z = 1.5

autoencoder = build_autoencoder(input_shape=(1500, 1), latent_dim=10, min_rest_x=min_observed_x/(1+max_z), max_rest_x=max_observed_x/(1+min_z), observed_resolution=observed_resolution, upsample_factor=2)

autoencoder.compile(optimizer='adam', loss='mse')
autoencoder.summary()