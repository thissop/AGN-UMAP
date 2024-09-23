import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.utils.data import DataLoader, TensorDataset, random_split
import numpy as np
from scipy.ndimage import gaussian_filter1d
from astropy.io import fits
import os
from torchinterp1d import interp1d

# Encoder Model
class Encoder(nn.Module):
    def __init__(self, input_shape, latent_dim):
        super(Encoder, self).__init__()
        self.conv1 = nn.Conv1d(1, 128, kernel_size=5)
        self.prelu1 = nn.PReLU()
        self.pool1 = nn.MaxPool1d(2)

        self.conv2 = nn.Conv1d(128, 256, kernel_size=11)
        self.prelu2 = nn.PReLU()
        self.pool2 = nn.MaxPool1d(2)

        self.conv3 = nn.Conv1d(256, 512, kernel_size=21)
        self.prelu3 = nn.PReLU()
        self.pool3 = nn.MaxPool1d(2)

        self.flatten = nn.Flatten()
        self.fc1 = nn.Linear(89088, 256) # calculation is off, this is based on hard coded values
        #self.fc1 = nn.Linear(512 * ((input_shape[0] - 21 + 1) // 2 // 2 // 2), 256)
        self.prelu4 = nn.PReLU()
        self.fc2 = nn.Linear(256, 128)
        self.prelu5 = nn.PReLU()
        self.fc3 = nn.Linear(128, 64)
        self.prelu6 = nn.PReLU()

        self.latent_space = nn.Linear(64, latent_dim)

    def forward(self, x):
        x = self.pool1(self.prelu1(self.conv1(x)))
        x = self.pool2(self.prelu2(self.conv2(x)))
        x = self.pool3(self.prelu3(self.conv3(x)))
        x = self.flatten(x)
        #print(x.shape)
        #quit()
        x = self.prelu4(self.fc1(x))
        x = self.prelu5(self.fc2(x))
        x = self.prelu6(self.fc3(x))
        latent = self.latent_space(x)
        return latent

# Decoder Model
class Decoder(nn.Module):
    def __init__(self, latent_dim, output_dim, rest_range, observed_range, observed_resolution, upsample_factor):
        super(Decoder, self).__init__()
        self.fc1 = nn.Linear(latent_dim, 64)
        self.prelu1 = nn.PReLU()
        self.fc2 = nn.Linear(64, 256)
        self.prelu2 = nn.PReLU()
        self.fc3 = nn.Linear(256, 1024)
        self.prelu3 = nn.PReLU()

        min_rest_x, max_rest_x = rest_range
        rest_length = int((max_rest_x - min_rest_x) / observed_resolution * upsample_factor)
        self.rest_length = rest_length

        self.fc4 = nn.Linear(1024, rest_length)
        self.prelu4 = nn.PReLU()

        self.observed_range = observed_range
        self.output_dim = output_dim

    def forward(self, latent_input, z_input):
        x = self.prelu1(self.fc1(latent_input))
        x = self.prelu2(self.fc2(x))
        x = self.prelu3(self.fc3(x))

        x = self.prelu4(self.fc4(x))

        # Downsample with interpolation # --> this needs to be fixed? interesting approach. 
        obs_x = torch.linspace(self.observed_range[0], self.observed_range[1], self.output_dim).to(latent_input.device)
        rest_x = torch.linspace(self.observed_range[0], self.observed_range[1], self.rest_length).to(latent_input.device)

        rest_x_redshifted = rest_x * (1 + z_input.unsqueeze(1))
        interpolated_output = interp1d(obs_x, rest_x_redshifted, x)

        return interpolated_output

# Autoencoder Model
class Autoencoder(nn.Module):
    def __init__(self, input_shape, latent_dim, z_range, observed_range, observed_resolution, upsample_factor):
        super(Autoencoder, self).__init__()
        self.encoder = Encoder(input_shape, latent_dim)
        rest_range = [observed_range[0] / (1 + z_range[1]), observed_range[1] / (1 + z_range[0])]
        self.decoder = Decoder(latent_dim, input_shape[0], rest_range, observed_range, observed_resolution, upsample_factor)

    def forward(self, spectra_input, z_input):
        latent_space = self.encoder(spectra_input)
        reconstructed_output = self.decoder(latent_space, z_input)
        return reconstructed_output

# Instantiate and train the model
observed_range = [3550, 10400]
observed_length = 1500
observed_resolution = (observed_range[1] - observed_range[0]) / observed_length
z_range = [1.5, 2.2]
upsample_factor = 2

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
autoencoder = Autoencoder(input_shape=(1500, 1), latent_dim=10, z_range=z_range, observed_range=observed_range,
                          observed_resolution=observed_resolution, upsample_factor=upsample_factor).to(device)

optimizer = torch.optim.Adam(autoencoder.parameters(), lr=1e-3)
loss_fn = nn.MSELoss()

print('### MODEL HAS BEEN LOADED ###')

import os
import numpy as np
import torch
from torch.utils.data import TensorDataset, random_split, DataLoader
from scipy.ndimage import gaussian_filter1d
from astropy.io import fits

data_dir = '/Users/tkiker/Documents/GitHub/AGN-UMAP/data/sdss_spectra'

file_names = []
spectra = []
zs = []

x = np.linspace(observed_range[0], observed_range[1], observed_length)

for file_name in os.listdir(data_dir)[0:500]:
    hdul = fits.open(os.path.join(data_dir, file_name))
    
    z = hdul[2].data['z'][0]

    if z_range[0] <= z <= z_range[1]:

        data = hdul[1].data

        wavelength = 10 ** data["loglam"]
        flux = data["flux"]

        # Apply a Gaussian filter to smooth the flux
        flux = gaussian_filter1d(flux, sigma=3)

        # Interpolate the flux to match the x array
        flux = np.interp(x, wavelength, flux)

        # Convert to rest-frame wavelength
        rest_wavelength = x / (1 + z)

        # Normalize the flux using a range of rest wavelengths
        norm_mask = np.logical_and(rest_wavelength >= 2000, rest_wavelength <= 2500)
        flux /= np.median(flux[norm_mask])

        spectra.append(flux)
        file_names.append(file_name)
        zs.append(z)

# Convert lists to numpy arrays
spectra = np.array(spectra)
zs = np.array(zs)

# Convert numpy arrays to PyTorch tensors
spectra_tensor = torch.tensor(spectra, dtype=torch.float32).unsqueeze(1)  # Add channel dimension
zs_tensor = torch.tensor(zs, dtype=torch.float32).unsqueeze(1)  # Make sure z is in the right shape for input

# Split data into training and test sets
dataset = TensorDataset(spectra_tensor, zs_tensor)

# Calculate lengths for train/test split
train_size = int(0.8 * len(dataset))
test_size = len(dataset) - train_size

# Randomly split the dataset
train_dataset, test_dataset = random_split(dataset, [train_size, test_size])

# Create DataLoaders for batching
batch_size = 16
train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
test_loader = DataLoader(test_dataset, batch_size=batch_size)

print(f"Training set size: {len(train_dataset)}")
print(f"Test set size: {len(test_dataset)}")

print("### DATA HAS BEEN LOADED ###")

# Training loop
num_epochs = 5
train_losses = []
test_losses = []

for epoch in range(num_epochs):
    autoencoder.train()
    train_loss = 0.0

    # Training phase
    for spectra_batch, zs_batch in train_loader:
        spectra_batch, zs_batch = spectra_batch.to(device), zs_batch.to(device)

        optimizer.zero_grad()
        output = autoencoder(spectra_batch, zs_batch)
        loss = loss_fn(output, spectra_batch.squeeze(1))
        loss.backward()
        optimizer.step()

        train_loss += loss.item()

    # Calculate average train loss
    avg_train_loss = train_loss / len(train_loader)
    train_losses.append(avg_train_loss)

    # Evaluation phase
    autoencoder.eval()
    test_loss = 0.0
    with torch.no_grad():
        for spectra_batch, zs_batch in test_loader:
            spectra_batch, zs_batch = spectra_batch.to(device), zs_batch.to(device)

            output = autoencoder(spectra_batch, zs_batch)
            loss = loss_fn(output, spectra_batch.squeeze(1))
            test_loss += loss.item()

    # Calculate average test loss
    avg_test_loss = test_loss / len(test_loader)
    test_losses.append(avg_test_loss)

    print(f"Epoch {epoch+1}/{num_epochs}, Train Loss: {avg_train_loss}, Test Loss: {avg_test_loss}")

# Plot loss history
plt.figure(figsize=(10, 6))
plt.plot(train_losses, label='Train Loss')
plt.plot(test_losses, label='Test Loss')
plt.title('Loss History')
plt.xlabel('Epochs')
plt.ylabel('Loss')
plt.legend()
plt.show()