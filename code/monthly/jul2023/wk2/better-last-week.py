'''
Blue/Red configuration data for G270H because it has the most (88) sources with high resolution grating data

The wavelength coverage of the spectrum depends not only on the filter but also on the configuration of the FOS detectors (blue or red) and is

Configuration.FilterID λmin λmax
HST/FOS_RED.G270H 1628.91 8554.19 ==> only one 
HST/FOS_BLUE.G270H 1612.91 5568.73 => only two

what's next? is there a larger 750k dataset we can expand to with uniform sampling? I think I could use more direction for project, and have a regular meeting! 

'''

def get_data_files(): 
    import os 
    import pandas as pd
    import numpy as np

    d1 = 'data/Kuraszkiewicz2004AGNSpectra'

    for f in os.listdir(d1): 
        if '.csv' in f: 
            df = pd.read_csv(os.path.join(d1, f))
            min_wavelength = np.min(df['Wavelength (Ang)'])
            if np.abs(1628.91-min_wavelength) <= 5: 
                print(f)

get_data_files()
