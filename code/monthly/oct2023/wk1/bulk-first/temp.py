import matplotlib.pyplot as plt
import numpy as np
from astropy.io import fits
from fantasy_agn.tools import read_sdss
import fantasy_agn

plot_dir = 'code/monthly/oct2023/wk1/bulk-first/plots'

filenames = ['spec-11277-58450-0294.fits','spec-11277-58450-0300.fits',
             'spec-11277-58450-0313.fits','spec-11277-58450-0699.fits',
             'spec-11277-58450-0705.fits','spec-11277-58450-0708.fits',
             'spec-11277-58450-0712.fits','spec-11277-58450-0720.fits']

filenames = [f'data/190SDSSspec/{i}' for i in filenames]

filepath = filenames[0]

#s=read_sdss(filepath)
#s.CorRed()
#s.fit_host_sdss()
hdul = fits.open(filepath)

hdulist = fits.open(filepath)
hdu = hdulist[1]
data = hdu.data

y = data.flux
x = 10 ** (data.loglam)
iv = data.ivar

fig, axs = plt.subplots(1,2)

axs[0].plot(x,y)
#axs[1].plot(data.wave, data.flux)
plt.show()
plt.clf()
plt.close()

'''
s.crop(3000, 7000)
plt.title(s.name.split('/')[-1].split('.')[0])
plt.show()
#plt.savefig(f'{plot_dir}/temp_data_only.png')
plt.clf()
plt.close()
'''