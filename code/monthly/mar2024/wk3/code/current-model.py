import tensorflow as tf
from tensorflow import keras 

input_img = keras.layers.Input(shape=(1024, 1))  # Add the channel dimension

# Convolutional Layers --> kernel_size? padding? filters? kernel size (increasing 579 or just 999)? attention layer? drop out?

# fix conv blocks? 

# Convolutional blocks
conv1 = keras.layers.Conv1D(filters=32, kernel_size=9, activation='relu')(input_img)
pool1 = keras.layers.MaxPool1D(pool_size=2)(conv1)

conv2 = keras.layers.Conv1D(filters=64, kernel_size=9, activation='relu')(pool1)
pool2 = keras.layers.MaxPool1D(pool_size=2)(conv2)

conv3 = keras.layers.Conv1D(filters=128, kernel_size=9, activation='relu')(pool2)
pool3 = keras.layers.MaxPool1D(pool_size=2)(conv3)

# Attention layer

# NEED TO ADD THIS 

# Dense layer
flatten = keras.layers.Flatten()(pool3)
encoded = keras.layers.Dense(8)(flatten)

# decoder 

decoded = keras.layers.Dense(64)(encoded)
decoded = keras.layers.Dense(128)(decoded)
decoded = keras.layers.Dense(256)(decoded)

# Create model
model = tf.keras.models.Model(inputs=input_img, outputs=decoded)

# Print model summary
print(model.summary())


# split into encoder, decoder, and unified autoencoder so i can get just encoded parts for graphing
# training stuff 