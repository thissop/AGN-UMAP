import pandas as pd
import numpy as np
import os 
from fantasy_agn.tools import read_text
from scipy.interpolate import CubicSpline
import matplotlib.pyplot as plt

key = '/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/oct2023/wk1/bulk-first/list_of_spectra.csv'

df = pd.read_csv(key)
plates = df['PLATE']
mjds = df['MJD']
fiberids = df['FIBRID']
z_values = df['Z']


sum = 0
lower, upper = (3000, 5000)
n = int((upper-lower)/2)
x = np.linspace(lower, upper, n)

for plate, mjd, fiberid, z in zip(plates, mjds, fiberids, z_values):
    fiberid = (4-len(str(fiberid)))*'0'+str(fiberid)
    string = f'{plate}-{mjd}-{fiberid}'
    data_path = f'code/monthly/oct2023/wk1/bulk-first/data/processed_data/spec-{string}.csv'
    if os.path.exists(data_path): 
        s = read_text(data_path)

        s.CorRed(redshift=z)
        s.crop(lower, upper)
        flux = s.flux
        wave = s.wave

        if len(flux)>n and max(wave)>upper-50: 
            cs = CubicSpline(wave, flux)
            y = cs(x)
            y = y/np.max(flux) # do this as alternative, then do outliers removal? estimate via neighbors?

            fig, ax = plt.subplots()
            ax.plot(x,y, label='interp')
            ax.scatter(wave, flux/np.max(flux), label='real')
            ax.set(xlabel='wavelength', ylabel='flux')
            ax.legend()
            fig.tight_layout()
            plt.savefig(f'code/monthly/oct2023/wk1/bulk-first/plots/cubic_interpolation/{string}.png')
            plt.clf()
            plt.close()

            df = pd.DataFrame()
            df['x'] = x
            df['y'] = y
            #df['wave'] = wave
            #df['flux'] = flux
            df.to_csv(f'code/monthly/oct2023/wk1/bulk-first/data/final_data/{string}.csv', index=False)