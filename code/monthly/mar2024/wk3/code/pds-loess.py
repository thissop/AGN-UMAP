from astropy.io import fits
import matplotlib.pyplot as plt 
import numpy as np
import pandas as pd
import os 
import numpy as np
from scipy.signal import savgol_filter
import statsmodels.api as sm
lowess = sm.nonparametric.lowess



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
    pds_data = np.array(pds_hdul[1].data)
    rms_squared = np.array([arr[1] for arr in pds_data])

    rsp_file = pds_file.replace('bin.pds', 'fak.rsp')
    rsp_hdul = fits.open(rsp_file)
    rsp_data = np.array(rsp_hdul[1].data)
    channel_widths = np.array([arr[2]-arr[1] for arr in rsp_data])
    channel_hz = np.array([(arr[2]+arr[1])/2 for arr in rsp_data])

    rms_squared = rms_squared/channel_widths

    mask = np.logical_and(channel_hz>1, channel_hz<=10)

    channel_hz = channel_hz[mask]
    rms_squared = rms_squared[mask]


    def make_pds_spec_plot(): 

        fig, axs  = plt.subplots(1, 2, figsize=(8, 4))
        channel, counts = spec_df['CHANNEL'], spec_df['COUNTS']
        axs[0].scatter(channel, counts)
        axs[0].plot(channel, savgol_filter(counts, 25, 3, mode='nearest'), color='red')
        axs[0].set(xlabel='Channel', ylabel='Counts', title='NICER Energy Spectrum', xscale='log')

        axs[1].scatter(channel_hz, rms_squared)
        axs[1].plot(channel_hz, savgol_filter(rms_squared, 4, 3, mode='nearest'), color='red')
        lowess_fit = lowess(rms_squared, channel_hz, frac=1/10).T
        axs[1].plot(lowess_fit[0], lowess_fit[1], color='green')
        axs[1].set(label='Index', ylabel='Power', title='Power Density Spectrum')

        plt.show()
        plt.close()

    make_pds_spec_plot()

    input_data.append(spec_df['COUNTS'].to_list())
    output_data.append(rms_squared)