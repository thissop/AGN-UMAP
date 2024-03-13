import numpy as np
import pandas as pd 
from astropy.io import fits

fits_path = '/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/oct2023/wk4/download-data/data/spSpec-4216-55477-310.fits'
output_path = '/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/nov2023/wk1/qsofitmore/data/spSpec-4216-55477-310.csv'

data = fits.open(fits_path)
wave = 10 ** data[1].data['loglam']  # OBS wavelength [A]
flux = data[1].data['flux']  # OBS flux [erg/s/cm^2/A]
err = np.nan_to_num(1 / np.sqrt(data[1].data['ivar']), nan=0.0)  # 1 sigma error
z = data[2].data['z'][0]  # Redshift

df = pd.DataFrame()
df['lam'] = wave
df['flux'] = flux
df['err'] = err

df.to_csv(output_path, index=False)