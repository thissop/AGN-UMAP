import os
import spender
import torch
from accelerate import Accelerator
import shutil 
from tqdm import tqdm 

# Hardware optimization
accelerator = Accelerator(mixed_precision='fp16')

# Get code, instrument, and pretrained spectrum model from the hub
sdss, model = spender.hub.load('sdss_II', map_location=accelerator.device)

# Move the model to the accelerator device (CUDA)
model.to(accelerator.device)

# Get some SDSS spectra from the ids, store locally in data_path
data_path = "./DATA"


ids = (2942, 54521, 215) #((412, 52254, 308), (412, 52250, 129), (685, 52203, 467))
spec, w, z, norm, zerr = sdss.make_batch(data_path, ids)

# Move tensors to the accelerator device
spec = spec.to(accelerator.device)
z = z.to(accelerator.device)

# For more fine-grained control, run spender's internal _forward method
# which return the latents s, the model for the restframe, and the observed spectrum
with torch.no_grad():
    s, spec_rest, spec_reco = model._forward(spec, instrument=sdss, z=z)

# Optionally, move results back to CPU if needed
s = s.cpu()
spec_rest = spec_rest.cpu().detach().numpy()
spec_reco = spec_reco.cpu().detach().numpy()

print(type(spec_rest))

import matplotlib.pyplot as plt
import smplotlib
import numpy as np

# Function to read the spectrum from the FITS file
def read_spectrum_from_fits(file_path):
    from astropy.io import fits
    with fits.open(file_path) as hdul:
        data = hdul[1].data
        wavelength = 10**data['loglam']  # Convert log wavelength to linear scale
        flux = data['model']
    return wavelength, flux

# File path
file_path = r'C:\Users\tkiker\Documents\GitHub\AGN-UMAP\data\0412\spec-0412-52254-0308.fits'

# Read the spectrum
wavelength, flux = read_spectrum_from_fits(file_path)

# Plot the original spectrum in black
plt.plot(np.arange(0, len(spec_reco[0])), spec_reco[0], label='Reconstruction')
plt.plot(np.arange(0, len(flux))+49, flux, label='Observed')
plt.xlabel('Flux Index')
plt.ylabel('Normalized Flux')
plt.title('0412-52254-0308')
plt.legend()
plt.savefig('normalized.png')
plt.show()