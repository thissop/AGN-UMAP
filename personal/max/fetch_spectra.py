from astroquery.sdss import SDSS
from astropy.io import fits
import h5py

def download_sdss_spectra(num_spectra):
    specobj_ids = []  # Empty list to store specobj_ids

    # Generating a list of specobj_ids
    for i in range(num_spectra):
        specobj_id = input(f"Enter specobj_id #{i+1}: ")
        specobj_ids.append(specobj_id)

    # Downloading and storing spectra
    spectra = []
    for specobj_id in specobj_ids:
        try:
            query = f"SELECT plate, fiberid, mjd FROM SpecObj WHERE specobjid = {specobj_id}"
            result = SDSS.query_sql(query)
            plate = result['plate'][0]
            fiberid = result['fiberid'][0]
            mjd = result['mjd'][0]
            sp = SDSS.get_spectrum(plate=plate, fiberID=fiberid, mjd=mjd)
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

# Prompt the user to enter the number of spectra to download
num_spectra = int(input("Enter the number of SDSS spectra to download: "))
download_sdss_spectra(num_spectra)