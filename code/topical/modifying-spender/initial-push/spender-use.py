import torch
import pandas as pd 
from spender.data.sdss import BOSS
import matplotlib.pyplot as plt
#import smplotlib
import os 
import numpy as np
from astropy.io import fits 

github = "pmelchior/spender"
sdss, model = torch.hub.load(github, 'sdss_II', map_location=torch.device('cpu'))

plates = []
mjds = []
fiberids = []

waves = []
fluxes = []

dir = '/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/data/sdss-qso-catalogue/spectra'
for sub_dir in os.listdir(dir)[0:10]: 
    if '.' not in sub_dir:
        sub_dir = os.path.join(dir, sub_dir)
        for file in os.listdir(sub_dir): 
            if '.1' not in file: 
                file_list = file.split('-')
                plates.append(int(file_list[1]))
                mjds.append(int(file_list[2]))
                fiberids.append(int(file_list[3].split('.')[0]))

                hdul = fits.open(os.path.join(sub_dir, file))

                for i in hdul[1].header.values():
                    waves.append(10**hdul[1].data['loglam'])
                    fluxes.append(hdul[1].data['model']) # flux is raw, model is smoothed

n_obs = 20

ids = list((plates[i], mjds[i], fiberids[i]) for i in range(n_obs))

spec, w, z, norm, zerr = BOSS.make_batch(dir, ids)

with torch.no_grad():
  s, spec_rest, spec_reco = model._forward(spec, instrument=sdss, z=z)

spec = spec.numpy()
#spec_reco = spec_reco.numpy()

mask = ~np.isnan(spec).any(axis=1)

waves = np.array(waves[0:n_obs])[mask]
fluxes = np.array(fluxes[0:n_obs])[mask]

#waves = np.array([waves[i]/(1+z.numpy()[i]) for i in range(len(waves))])

#print(model.wave_rest.numpy().shape, model.wave_obs.numpy().shape, spec_reco.numpy().shape, spec_rest.numpy().shape, spec.numpy().shape)
# add ID
 
fig, axs = plt.subplots(2, 1, sharex=True, figsize=(6,6))

# add model
axs[0].plot(waves[2], fluxes[2], c='black')
axs[0].plot(model.wave_obs.numpy(), spec_reco.numpy()[mask][2], c='red', label='Reconstruction')
#axs[0].get_xaxis().set_visible(False)
#axs[0].set_xlim(wave_model[0], wave_model[-1])

# residuals
#axs[1].plot(wave, (spec.cpu() - spec_reco) * w.sqrt().cpu(), c='k', drawstyle='steps-mid')
#axs[1].set_ylabel(r'Residuals [$\sigma$]')
#axs[1].set_xlabel(f'{frame} Wavelength [Å]')
#axs[1].set_xlim(wave[0], wave[-1])

plt.show()