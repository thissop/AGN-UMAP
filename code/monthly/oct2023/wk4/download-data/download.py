import numpy as np                  
import pandas as pd                 
import matplotlib.pyplot as plt 
import urllib.request
from astropy.io import fits
import os

# http://www.astroml.org/user_guide/datasets.html#sdss-data

plate = 11277
fiber = 294
mjd = 58450
ra = 0.0042214009
dec = 8.0729291

def download(plate, fiber, mjd, ra, url): 

    sdss_link = f'https://dr18.sdss.org/optical/spectrum/view/data/format%3Dfits/spec%3Dlite?plateid={plate}&mjd={mjd}&fiberid={fiber}'
    sdss_file = f'/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/oct2023/wk4/download-data/data/spSpec-{plate}-{mjd}-{fiber}.fits'
    plot_path = f'/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/oct2023/wk4/download-data/plots/spectra/spSpec-{plate}-{mjd}-{fiber}.png'
    im_path = f'/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/oct2023/wk4/download-data/plots/skyplot/spSpec-{plate}-{mjd}-{fiber}.png'

    im_url = f'https://skyserver.sdss.org/dr18/SkyServerWS/ImgCutout/getjpeg?TaskName=Skyserver.Explore.Image&ra={ra}%20&dec={dec}&scale=0.2&width=200&height=200&opt=G'

    urllib.request.urlretrieve(sdss_link, sdss_file)
    urllib.request.urlretrieve(im_url, im_path)

    data = fits.open(sdss_file)
    wave = 10 ** data[1].data['loglam']  # OBS wavelength [A]
    flux = data[1].data['flux']  # OBS flux [erg/s/cm^2/A]

    fig, ax = plt.subplots()

    ax.plot(wave, flux)
    ax.set(xlabel='wavelength', ylabel='flux')
    plt.savefig(plot_path)
    plt.close()
    plt.clf()

df = pd.read_csv('code/monthly/oct2023/wk1/bulk-first/list_of_spectra.csv')

plates, mjds, fibers, ras, decs = [df[i] for i in ['PLATE','MJD','FIBRID','RA','DEC']]
for plate, mjd, fiber, ra, dec in zip(plates, mjds, fibers, ras, decs):
    if os.path.exists(f'/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/oct2023/wk4/download-data/data/spSpec-{plate}-{mjd}-{fiber}.fits'):
        continue
    else: 
        download(plate, fiber, mjd, ra, dec)
