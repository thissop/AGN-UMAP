from tensorflow.keras.layers import Conv1D, MaxPooling1D, Flatten, Dense, PReLU, Input, Reshape
from tensorflow.keras.models import Model

def build_autoencoder(input_shape, latent_dim):
    # Input Layer
    spectra_input = Input(shape=input_shape, name='spectra_input')

    # Encoder Part
    x = Conv1D(filters=128, kernel_size=5, padding='valid', name='conv1')(spectra_input)
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

    # Fully Connected Layers (Latent Space)
    x = Dense(256, name='dense1')(x)
    x = PReLU(name='prelu4')(x)
    x = Dense(128, name='dense2')(x)
    x = PReLU(name='prelu5')(x)
    x = Dense(64, name='dense3')(x)
    x = PReLU(name='prelu6')(x)
    latent_space = Dense(latent_dim, name='latent_space')(x)

    # Decoder Part
    x = Dense(64)(latent_space)
    x = PReLU()(x)
    x = Dense(256)(x)
    x = PReLU()(x)
    x = Dense(1024)(x)
    x = PReLU()(x)
    x = Dense(input_shape[0])(x)
    reconstructed_output = Reshape((input_shape[0], 1))(x)

    # Autoencoder Model
    return Model(inputs=spectra_input, outputs=reconstructed_output, name='autoencoder')

# Define and compile the autoencoder model
autoencoder = build_autoencoder(input_shape=(1500, 1), latent_dim=10)
autoencoder.compile(optimizer='adam', loss='mse')

# Save the model
autoencoder.save('autoencoder_model.h5')

# Optionally, visualize the model
from tensorflow.keras.utils import plot_model
plot_model(autoencoder, to_file='autoencoder_architecture.png', show_shapes=True, show_layer_names=True, dpi=300)
