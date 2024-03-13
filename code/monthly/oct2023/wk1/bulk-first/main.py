import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Input, Dense
from tensorflow.keras.callbacks import EarlyStopping
from tensorflow.keras.utils import plot_model
from sklearn.preprocessing import LabelEncoder
import umap
import os

data_directory = 'code/monthly/oct2023/wk1/bulk-first/data/final_data/'
data = []
types = []

info_df = pd.read_csv('')
info_ids = np.array(info_df['SpectraName'])

for filename in os.listdir(data_directory):
    csv_path = os.path.join(data_directory, filename)
    df = pd.read_csv(csv_path)
    wavelength = np.array(df['x'])
    flux = np.array(df['y'])
    data.append(flux)

data = np.array(data)

# Prep Data and Model

X_train, X_test = train_test_split(data, test_size=0.2, random_state=42)

input_dim = X_train.shape[1]
encoding_dim = 32

input_layer = Input(shape=(input_dim,))
encoder = Dense(encoding_dim, activation='relu')(input_layer)
decoder = Dense(input_dim, activation='sigmoid')(encoder)

autoencoder = Model(input_layer, decoder)

# Compile and Train the Model
autoencoder.compile(optimizer='adam', loss='mse')

early_stopping = EarlyStopping(patience=5, restore_best_weights=True)
history = autoencoder.fit(X_train, X_train, epochs=200, batch_size=32, validation_data=(X_test, X_test), callbacks=[early_stopping])

# Plot the loss curve
plt.plot(history.history['loss'], label='Training Loss')
plt.plot(history.history['val_loss'], label='Validation Loss')
plt.xlabel('Epochs')
plt.ylabel('Loss')
plt.title('Autoencoder Training')
plt.legend()
plt.savefig('encoder.png', dpi=250)
plt.clf()
plt.close()

# Plot the encoder structure
plot_model(autoencoder, to_file='encoder_structure.png', show_shapes=True)

# Get the encoded representation of the input data
encoder_model = Model(input_layer, encoder)
encoded_data = encoder_model.predict(X_test)

# Perform dimensionality reduction using UMAP

reducer = umap.UMAP(n_components=2)
reduced_data = reducer.fit_transform(encoded_data)

# Plot the Reduced Data 

plt.scatter(reduced_data[:, 0], reduced_data[:, 1], s=5)
plt.title("UMAP Visualization of Encoded Data")
plt.xlabel("UMAP Dimension 1")
plt.ylabel("UMAP Dimension 2")
plt.savefig('personal/thaddaeus/monthly/june2023/wk4/analysis-plots/umap.png', dpi=250)

# Goals for today: 
'''
1. plot of data points per file
2. get data pipeline for model estimated and cubic interpolation 
3. do agn/autoencoder for both ^^^ 
'''