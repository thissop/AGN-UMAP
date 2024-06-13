import os
import spender
import torch
from accelerate import Accelerator

# hardware optimization
accelerator = Accelerator(mixed_precision='fp16', cpu=True)

# get code, instrument, and pretrained spectrum model from the hub
sdss, model = spender.hub.load('sdss_II',  map_location=accelerator.device)

# get some SDSS spectra from the ids, store locally in data_path
data_path = "./DATA"

ids = ((412, 52254, 308), (412, 52250, 129), (685,52203,467))
spec, w, z, norm, zerr = sdss.make_batch(data_path, ids)

# for more fine-grained control, run spender's internal _forward method
# which return the latents s, the model for the restframe, and the observed spectrum
with torch.no_grad():
    s, spec_rest, spec_reco = model._forward(spec, instrument=sdss, z=z)

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
plt.plot(wavelength, flux, color='black', label='Original Spectrum')
plt.plot(10 ** np.arange(3.578, 3.97, 0.0001),  spec_reco[0], color='red', label='Reconstruction')
plt.title('0412-52250-0129')
plt.xlabel('Wavelength (Å)')
plt.ylabel('Flux')
plt.legend()
plt.savefig('plot.png', dpi=200)
plt.show()