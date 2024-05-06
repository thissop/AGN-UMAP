import tensorflow as tf
from tensorflow.keras import Model, Input
from tensorflow.keras.layers import Dense, Conv1D, Flatten, Reshape, LeakyReLU, Layer

def build_autoencoder(input_shape=(3921, 1), latent_dim=6):
    inputs = Input(shape=input_shape)

    # Encoder
    x = Conv1D(filters=32, kernel_size=5, padding='same', activation='relu')(inputs)
    x = Conv1D(filters=64, kernel_size=11, padding='same', activation='relu')(x)
    x = Conv1D(filters=128, kernel_size=21, padding='same', activation='relu')(x)
    x = Dense(128, activation='relu')(x)
    x = Dense(64, activation='relu')(x)
    latent_space = Dense(latent_dim, activation='relu')(x)

    # Decoder
    x = Dense(64, activation='relu')(latent_space)
    x = Dense(128, activation='relu')(x)
    x = Dense(256, activation='relu')(x)
    x = Flatten()(x)
    x = Dense(input_shape[0] * input_shape[1], activation='relu')(x) 
    decoded = Reshape(input_shape)(x)

    autoencoder = Model(inputs=inputs, outputs=decoded)
    return autoencoder

print('about to build')

autoencoder = build_autoencoder()
autoencoder.compile(optimizer='adam', loss='mse')
print(autoencoder.summary())

print('something happened')

import os 
from astropy.io import fits 
import numpy as np 

train_dir = '/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/data/sdss-qso-catalogue/mini-batch/fits/train/7167'
train_data = [os.path.join(train_dir, i) for i in os.listdir(train_dir)]
train_data = np.array([fits.open(i)[1].data['model'] for i in train_data])

val_dir = '/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/data/sdss-qso-catalogue/mini-batch/fits/train/7167'
val_data = [os.path.join(val_dir, i) for i in os.listdir(val_dir)]
val_data = np.array([fits.open(i)[1].data['model'] for i in val_data])

scale = np.max([np.max(val_data), np.max(train_data)])

#from tensorflow.keras.callbacks import EarlyStopping

#early_stopping = EarlyStopping(monitor='val_loss', patience=10, restore_best_weights=True)

history = autoencoder.fit(
    train_data, train_data,  # autoencoders are trained to reconstruct the input
    epochs=5,
    batch_size=1,
    validation_data=(val_data, val_data),
    #callbacks=[early_stopping]
)

val_loss = autoencoder.evaluate(train_data, val_data)
print("Validation loss:", val_loss)
