def convert_log(): 
    import re
    lines = []
    file = 'code/monthly/oct2023/wk1/bulk-first/list_of_spectra.txt'
    with open(file, 'r') as f: 
        for line in f: 
            line = re.sub(' +', ',', line)
            lines.append(line)

    with open(file, 'w') as f: 
        for line in lines: 
            f.write(line)

#convert_log()

def convert_files():
    import os 
    from astropy.io import fits 
    import numpy as np
    import pandas as pd

    d1 = '/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/data/190SDSSspec/'
    d2 = '/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/oct2023/wk1/bulk-first/processed_data/'
    for file in os.listdir(d1):
        fits_file = d1+file

        hdulist = fits.open(fits_file)
        hdu = hdulist[1]
        data = hdu.data

        x = 10 ** (data.loglam)
        y = data.flux

        df = pd.DataFrame()
        df['wavelength'] = x
        df['flux'] = y
        #try:
        np.savetxt(fname=d2+file.replace('.fits', '.csv'), X=df)
        #except:
        #    continue 

convert_files()