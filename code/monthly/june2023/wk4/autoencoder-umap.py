import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import MinMaxScaler
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Input, Dense
from tensorflow.keras.callbacks import EarlyStopping
from tensorflow.keras.utils import plot_model

import os
import pandas as pd
import numpy as np

data_directory = 'data/ProcessedSpectra' 
data = []

extra_info_df = pd.read_csv('personal/thaddaeus/monthly/june2023/wk4/table-1.csv')
extra_info_ids = np.array(extra_info_df['SpectraName'])

# Create a dictionary to map unique object classes to numeric labels
class_labels = {cls: i for i, cls in enumerate(extra_info_df['Type'].unique())}

# Map object classes to numeric labels
extra_info_df['label'] = extra_info_df['Type'].map(class_labels)

types = []

for filename in os.listdir(data_directory):
    if filename.endswith('.csv'):
        spectra_name = filename.split('.')[0]
        idx = np.where(extra_info_ids==spectra_name)[0]
        obj_type = np.array(extra_info_df['Type'])[idx]
        if len(obj_type)>0: 
            obj_type = obj_type[0]
        else: 
            obj_type = 'None'
        types.append(obj_type)
        csv_path = os.path.join(data_directory, filename)
        df = pd.read_csv(csv_path)
        flux_array = np.array(df['Flux'])
        data.append(flux_array)

data = np.array(data)

print(data.shape)

# Split the data into training and testing sets
X_train, X_test, types_train, types_test = train_test_split(data, types, test_size=0.2, random_state=42)

# Define the autoencoder architecture
input_dim = X_train.shape[1]
encoding_dim = 32

input_layer = Input(shape=(input_dim,))
encoder = Dense(encoding_dim, activation='relu')(input_layer)
decoder = Dense(input_dim, activation='sigmoid')(encoder)

autoencoder = Model(input_layer, decoder)

# Compile the model
autoencoder.compile(optimizer='adam', loss='mse')

# Train the autoencoder
early_stopping = EarlyStopping(patience=5, restore_best_weights=True)
history = autoencoder.fit(X_train, X_train, epochs=200, batch_size=32, validation_data=(X_test, X_test), callbacks=[early_stopping])

# Plot the loss curve
plt.plot(history.history['loss'], label='Training Loss')
plt.plot(history.history['val_loss'], label='Validation Loss')
plt.xlabel('Epochs')
plt.ylabel('Loss')
plt.title('Autoencoder Training')
plt.legend()
plt.savefig('personal/thaddaeus/monthly/june2023/wk4/analysis-plots/encoder.png', dpi=250)

# Plot the encoder structure
plot_model(autoencoder, to_file='personal/thaddaeus/monthly/june2023/wk4/analysis-plots/encoder_structure.png', show_shapes=True)

# Get the encoded representation of the input data
encoder_model = Model(input_layer, encoder)
encoded_data = encoder_model.predict(X_test)

# Perform dimensionality reduction using UMAP
import umap

reducer = umap.UMAP(n_components=2)
reduced_data = reducer.fit_transform(encoded_data)

plt.clf()
plt.close()

# Plot the reduced data
from sklearn.preprocessing import LabelEncoder
 
# Creating a instance of label Encoder.
le = LabelEncoder()
 
# Using .fit_transform function to fit label
# encoder and return encoded label
labels = le.fit_transform(types_test)

plt.scatter(reduced_data[:, 0], reduced_data[:, 1], s=5, c=labels)
plt.title("UMAP Visualization of Encoded Data")
plt.xlabel("UMAP Dimension 1")
plt.ylabel("UMAP Dimension 2")
plt.savefig('personal/thaddaeus/monthly/june2023/wk4/analysis-plots/umap.png', dpi=250)

'''
In this code, we use Keras to define and train the autoencoder model. We compile the model using the Adam optimizer and mean squared error (MSE) loss. After training the autoencoder, we extract the encoded representation of the input data and perform dimensionality reduction using UMAP. Finally, we plot the reduced data using matplotlib.
'''