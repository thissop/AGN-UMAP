import tensorflow as tf
from tensorflow.keras.layers import Conv1D, MaxPooling1D, Flatten, Dense, PReLU, Input, Reshape, Lambda
from tensorflow.keras.models import Model
import tensorflow.keras.backend as K

def build_encoder(input_shape, latent_dim):
    input_layer = Input(shape=input_shape)

    # Convolutional Layers
    x = Conv1D(filters=128, kernel_size=5, padding='valid')(input_layer)
    x = PReLU()(x)
    x = MaxPooling1D(pool_size=2)(x)

    x = Conv1D(filters=256, kernel_size=11, padding='valid')(x)
    x = PReLU()(x)
    x = MaxPooling1D(pool_size=2)(x)

    x = Conv1D(filters=512, kernel_size=21, padding='valid')(x)
    x = PReLU()(x)
    x = MaxPooling1D(pool_size=2)(x)

    # Flatten the output from Conv layers
    x = Flatten()(x)

    # Fully Connected Layers
    x = Dense(256)(x)
    x = PReLU()(x)
    x = Dense(128)(x)
    x = PReLU()(x)
    x = Dense(64)(x)
    x = PReLU()(x)

    # Latent Space
    latent_space = Dense(latent_dim, name='latent_space')(x)

    return Model(input_layer, latent_space, name='encoder')

def build_decoder(latent_dim, output_dim, z_min, z_max, min_observed_wavelength, max_observed_wavelength):
    
    latent_input = Input(shape=(latent_dim,))
    redshift_input = Input(shape=(1,))

    # Calculate rest frame wavelength range
    min_rest_wavelength = min_observed_wavelength / z_max
    max_rest_wavelength = max_observed_wavelength / z_min
    rest_frame_range = max_rest_wavelength - min_rest_wavelength

    # Calculate observed resolution
    observed_resolution = (max_observed_wavelength - min_observed_wavelength) / output_dim

    # Calculate rest frame length with twice the resolution
    rest_frame_length = int((rest_frame_range / observed_resolution) * 2)

    # Fully Connected Layers to generate rest frame representation
    x = Dense(64)(latent_input)
    x = PReLU()(x)
    x = Dense(256)(x)
    x = PReLU()(x)
    x = Dense(1024)(x)
    x = PReLU()(x)
    x = Dense(rest_frame_length)(x)
    x = PReLU()(x)

    # Resample using linear interpolation based on redshift
    def resample_spectrum(inputs):
        spectrum, redshift = inputs
        observed_wavelengths = K.linspace(min_observed_wavelength, max_observed_wavelength, output_dim)
        rest_wavelengths = K.linspace(min_rest_wavelength, max_rest_wavelength, rest_frame_length)
        observed_wavelengths_shifted = observed_wavelengths / (1 + redshift)

        # Perform linear interpolation using tf.image.resize
        spectrum = K.expand_dims(K.expand_dims(spectrum, 0), -1)
        rest_wavelengths = K.expand_dims(K.expand_dims(rest_wavelengths, 0), -1)
        observed_wavelengths_shifted = K.expand_dims(K.expand_dims(observed_wavelengths_shifted, 0), -1)
        resampled_spectrum = tf.image.resize(spectrum, [observed_wavelengths_shifted.shape[1]], method='bilinear')
        resampled_spectrum = K.squeeze(resampled_spectrum, [0, -1])

        return resampled_spectrum

    resampled_spectrum = Lambda(resample_spectrum, output_shape=(output_dim,))([x, redshift_input])
    resampled_spectrum = Reshape((output_dim, 1))(resampled_spectrum)

    return Model([latent_input, redshift_input], resampled_spectrum, name='decoder')

def build_autoencoder(input_shape, latent_dim, z_min, z_max, min_observed_wavelength, max_observed_wavelength):
    encoder = build_encoder(input_shape, latent_dim)
    decoder = build_decoder(latent_dim=latent_dim, output_dim=input_shape[0], z_min=z_min, z_max=z_max, min_observed_wavelength=min_observed_wavelength, max_observed_wavelength=max_observed_wavelength)

    input_layer = Input(shape=input_shape)
    redshift_input = Input(shape=(1,))
    latent_space = encoder(input_layer)
    reconstructed_output = decoder([latent_space, redshift_input])

    return Model([input_layer, redshift_input], reconstructed_output, name='autoencoder')

# gaussian smooth and interpolate inputs 

import numpy as np 
from astropy.io import fits 
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt 
import smplotlib 
import os 
from scipy.ndimage import gaussian_filter1d

data_dir = '/Users/tkiker/Documents/GitHub/AGN-UMAP/data/sdss_spectra'

file_names = []
spectra = []
zs = []

x = np.linspace(3550, 10400, 4500)

for file_name in os.listdir(data_dir)[0:100]:
    hdul = fits.open(os.path.join(data_dir, file_name))
    
    data = hdul[1].data

    wavelength = 10**data["loglam"]
    flux = data["flux"]

    flux = gaussian_filter1d(flux, sigma=3)
    flux = np.interp(x, wavelength, flux)

    z = hdul[2].data['z'][0]

    rest_wavelength = x/(1+z)

    norm_mask = np.logical_and(rest_wavelength>=2000, rest_wavelength<=2500)
    flux /= np.median(flux[norm_mask])

    spectra.append(flux)
    file_names.append(file_name)
    zs.append(z)

model_input = [[i, j] for i, j in zip(spectra, zs)]

autoencoder = build_autoencoder(input_shape=(len(x), 1), latent_dim=10, z_min=1.5, z_max=2.2,
                                min_observed_wavelength=np.min(spectra),
                                max_observed_wavelength=np.max(spectra))

autoencoder.compile(optimizer='adam', loss='mse')
autoencoder.summary()


X_train, X_val = train_test_split(model_input, test_size=0.2, random_state=42)

# Train the autoencoder
history = autoencoder.fit(X_train, X_train, epochs=5, batch_size=4, validation_data=(X_val, X_val))

# Save the training history
history_dict = history.history

# Plot the training history
plt.figure(figsize=(12, 6))

# Plot training & validation loss values
plt.subplot(1, 2, 1)
plt.plot(history_dict['loss'])
plt.plot(history_dict['val_loss'])
plt.title('Model Loss')
plt.ylabel('Loss')
plt.xlabel('Epoch')
plt.legend(['Train', 'Validation'], loc='upper right')

# Show the plots
plt.show()