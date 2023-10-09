# 11279 58449  74 
# 11279 58449 956 
# 11279 58449 978

'''
from astroquery.sdss import SDSS  
specs = SDSS.get_spectra(plate=751, mjd=52251, fiberID=160, data_release=14)  
Spectrum1D.read(specs[0], format="SDSS-III/IV spec")
'''

# not sure about milky way corretion, just use hdul. 

from astropy.io import fits
from specutils import Spectrum1D
import matplotlib.pyplot as plt
from astroquery.sdss import SDSS  

plate = '11279'
fiberid = '74'
mjd = '58449'
fiberid = ''.join((4-len(fiberid))*['0'])+fiberid

file_path = f'data/190SDSSspec/spec-{plate}-{mjd}-{fiberid}.fits'

fits_image_filename = fits.util.get_testdata_filepath('test0.fits')
hdul = fits.open(fits_image_filename)
print(hdul.info())
#print(hdul[1].data)
#print(str(hdul[1].header).replace('/', '\n'))
print(hdul[0].data)
print(str(hdul[0].header).replace('/', '\n'))


#spec1d = Spectrum1D.read(fits_image_filename)  
# SDSS-I/II spSpec  Yes    No           Yes
# SDSS-III/IV spec  Yes    No           Yes


'''
fig, ax = plt.subplots()
ax.plot(spec1d.spectral_axis, spec1d.flux)  
ax.set_xlabel("Dispersion")  
ax.set_ylabel("Flux")  

plt.show()
'''