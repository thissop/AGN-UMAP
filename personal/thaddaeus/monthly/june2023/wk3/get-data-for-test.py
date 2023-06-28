# Here's an example code that queries and downloads AGN spectra from SDSS:
import numpy as np
from astroquery.sdss import SDSS
from astropy.io import fits
import h5py

specobj_ids = ['1237670965926490000']
# Downloading and storing spectra
spectra = []
for specobj_id in specobj_ids:
    try:
        query = f"SELECT plate, fiberid, mjd FROM SpecObj WHERE specobjid = {specobj_id}"
        result = SDSS.query_sql(query)
        plate = result['plate'][0]
        fiberid = result['fiberid'][0]
        mjd = result['mjd'][0]
        sp = SDSS.get_spectrum(plate=plate, fiberID=fiberid, mjd=mjd) # 266	5	146.93861	-0.68701194
        wavelength = sp.wavelength()
        flux = sp.flux
        spectra.append((wavelength, flux))
    except Exception as e:
        print(f"Error retrieving spectrum {specobj_id}: {e}")

# Saving spectra to HDF5 file
with h5py.File('agn_spectra.hdf5', 'w') as hf:
    for i, (wavelength, flux) in enumerate(spectra):
        group = hf.create_group(f'spectrum_{i}')
        group.create_dataset('wavelength', data=wavelength)
        group.create_dataset('flux', data=flux)