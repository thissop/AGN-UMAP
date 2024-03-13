from main import deredden
import matplotlib.pyplot as plt 
from astropy.io import fits
import pandas as pd
import numpy as np 
import os 

data_dir = '/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/oct2023/wk4/download-data/data/'

for f in os.listdir(data_dir):
    if '.fits' in f: 
        hdul = fits.open(os.path.join(data_dir, f))
        data = hdul[1].data

        x = 10 ** (data['loglam'])
        y = data['flux']
        z = hdul[2].data['z'][0]
        #err = np.nan_to_num(1 / np.sqrt(data['ivar']), nan=0) # only include good points instead? this is really jank

        fig, axs = plt.subplots(2, 1)

        axs[0].plot(x,y)
        axs[0].set(ylabel='Flux', xlabel='Wavelength', xlim=(3000,11000))
        axs[1].plot(*deredden(x,y, z))
        axs[1].set(xlabel='Corrected Wavelength', ylabel='Corrected Flux', xlim=(1000,4000))

        fig.tight_layout()

        plt.show()
        plt.clf()