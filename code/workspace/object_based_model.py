import numpy as np 
import tensorflow as tf
from tensorflow.keras.layers import Conv1D, MaxPooling1D, Flatten, Dense, PReLU, Input, Reshape, Layer, Lambda
from tensorflow.keras.models import Model
import tensorflow.keras.backend as K
from astropy.io import fits
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt
import os
from scipy.ndimage import gaussian_filter1d


class Spender():
    
    latent_dim = 10

    min_obs_x = 3550
    max_obs_x = 10400
    obs_length = 1500
    
    observed_resolution = None 

    z_range = [1.5, 2.2]
    
    upsample_factor = None 
    
    min_rest_x = None 
    max_rest_x = None
    rest_length = None

    observed_x = None 
    rest_x = None 

    def __init__(self, obs_length:int=None, observed_range:list=None, z_range:list=None, upsample_factor:int=None, latent_dim:int=None):
        
        if obs_length is not None: 
            self.obs_length = obs_length 
        
        if observed_range is not None: 
            self.min_obs_x = observed_range[0]
            self.max_obs_x = observed_range[1]

        if z_range is not None: 
            self.z_range = z_range

        if upsample_factor is not None: 
            self.upsample_factor = upsample_factor 

        self.observed_x = np.linspace(self.min_obs_x, self.max_obs_x, self.obs_length)
        
        self.min_rest_x = int(self.min_obs_x/(1+self.z_range[1]))
        self.max_rest_x = int(self.max_obs_x/(1+self.z_range[0]))
        observed_resolution = (self.max_obs_x-self.min_obs_x)/self.obs_length

        self.rest_length = int((self.max_rest_x - self.min_rest_x) / observed_resolution * self.upsample_factor)
        rest_x = np.linspace(self.min_rest_x, self.max_rest_x, self.rest_length)
        self.rest_x = rest_x

        if latent_dim is not None: 
            self.latent_dim = latent_dim

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

    def build_decoder(): 
        return None 

    def build_autoencoder():
        spectra_input = Input(shape=self.obs_length, name='spectra_input') # fix this in case obs length, which is an integer, isn't correct for this step, even if an integer accurately describes the length of an individual input vector. 
        
        # Building the encoder 
        encoder = build_encoder(self.obs_length, self.latent_dim)
        latent_space = encoder(spectra_input)
        
        # Scalar z input 
        z_input = Input(shape=(1,), name='z_input')
        
        # Building the decoder input  latent vector and scalar z

        decoder = build_decoder(latent_dim, input_shape[0], rest_range, observed_range, observed_resolution, upsample_factor)
        reconstructed_output = decoder([latent_space, z_input])

        return Model(inputs=[spectra_input, z_input], outputs=reconstructed_output, name='autoencoder')

spender = Spender(upsample_factor=2)
        

        
        

        
