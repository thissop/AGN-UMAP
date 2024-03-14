from astropy.io import fits
import matplotlib.pyplot as plt 
import numpy as np
import pandas as pd
import os 

spec_dir = '/Users/yaroslav/Documents/2. work/Research/GitHub/MAXI-J1535/final-push/data/sources/MAXI_J1535-571/raw_spectral/'

input_data = []
output_data = []

for spec_csv in os.listdir(spec_dir): 
    name_list = spec_csv.split('.')[0].split('_')

    obsid = name_list[0]
    gti = name_list[1]
    spec_df = pd.read_csv(os.path.join(spec_dir, spec_csv))

    pds_file = f'/Users/yaroslav/Documents/2. work/Research/GitHub/MAXI-J1535/final-push/data/sources/MAXI_J1535-571/regression/qpo/jspipe_qpo/{obsid}/js_ni{obsid}_0mpu7_silver_GTI{gti}-bin.pds'
    pds_hdul = fits.open(pds_file)
    pds_data = np.array(pds_hdul[1].data)[50:200]
    print(pds_data[0])

    idx = [i[0] for i in pds_data]
    power = [i[1] for i in pds_data]

    def make_pds_spec_plot(): 

        fig, axs  = plt.subplots(1, 2, figsize=(8, 4))

        axs[0].scatter(spec_df['CHANNEL'], spec_df['COUNTS'])
        axs[0].set(xlabel='Channel', ylabel='Counts', title='NICER Energy Spectrum')

        axs[1].scatter(idx, power)
        axs[1].set(label='Index', ylabel='Power', title='Power Density Spectrum')

        plt.show()

        plt.close()

    input_data.append(spec_df['COUNTS'].to_list())
    output_data.append(power)

