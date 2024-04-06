import tensorflow as tf
from tensorflow.keras import layers, models

# Define the autoencoder model
def autoencoder(input_shape):
    # Encoder
    inputs = layers.Input(shape=input_shape)
    x = inputs
    # Convolutional layers
    for _ in range(3):
        x = layers.Conv1D(filters=64, kernel_size=9, activation='relu', padding='same')(x)
        x = layers.MaxPooling1D(pool_size=2)(x)
    # Flatten the latent space
    x = layers.Flatten()(x)
    # Dense layers
    for _ in range(4):
        x = layers.Dense(256, activation='relu')(x)
    # Output layer
    outputs = layers.Dense(input_shape[0], activation='sigmoid')(x)
    
    # Decoder
    decoded = outputs
    # Reshape the output to match input shape
    decoded = tf.keras.layers.Reshape((input_shape[0], 1))(decoded)
    # Convolutional layers
    for _ in range(3):
        decoded = layers.Conv1D(filters=64, kernel_size=9, activation='relu', padding='same')(decoded)
        decoded = layers.UpSampling1D(size=2)(decoded)
    # Output layer
    decoded = layers.Conv1D(filters=1, kernel_size=9, activation='sigmoid', padding='same')(decoded)
    
    # Create the autoencoder model
    autoencoder = models.Model(inputs, decoded, name="autoencoder")
    return autoencoder

# Define input shape
input_shape = (1024, 1)

# Create autoencoder model
model = autoencoder(input_shape)

# Compile the model
model.compile(optimizer='adam', loss='mse')

# Display model summary
model.summary()
