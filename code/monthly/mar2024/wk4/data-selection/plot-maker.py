from astropy.io import fits
import matplotlib.pyplot as plt 
import numpy as np
import pandas as pd
import os 
import numpy as np
from scipy.signal import savgol_filter
import statsmodels.api as sm
lowess = sm.nonparametric.lowess
from tqdm import tqdm 

#/Users/yaroslav/Downloads/thaddaeus_delivery/2200500201/jspipe/js_ni2200500201_0mpu7_goddard_GTI0.jsgrp
#/Users/yaroslav/Downloads/thaddaeus_delivery/2200500201/jspipe/js_ni2200500201_0mpu7_silver_GTI0-bin.pds

spec_dir = '/Users/yaroslav/Downloads/thaddaeus_delivery'

input_data = []
output_data = []

for obsid in tqdm(os.listdir(spec_dir)): 
    if '.' not in obsid:
        sub_dir = os.path.join(spec_dir, obsid+'/jspipe')

        for gti in range(len(os.listdir(sub_dir))):
            pds_file = os.path.join(sub_dir, f'js_ni{obsid}_0mpu7_goddard_GTI{gti}-bin.pds')
            
            if os.path.exists(pds_file): 
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

                channel_hz = channel_hz[mask] # hz mid point for pds 
                rms_squared = rms_squared[mask] # data are in rms^2/channel width 

                spec_file = pds_file.replace('-bin.pds', '.jsgrp')

                energy_spec_hdul = fits.open(spec_file)
                energy_spec_data = np.array(energy_spec_hdul[1].data)

                energy_spec_channel = energy_spec_data['CHANNEL']
                energy_counts = energy_spec_data['COUNTS']

                energy_rsp_file = energy_spec_hdul[1].header['RESPFILE']

                energy_rsp_file = os.path.join(spec_dir, energy_rsp_file)
                energy_rsp_data = fits.open(energy_rsp_file)[1].data

                energy_means = (energy_rsp_data['E_MAX']+energy_rsp_data['E_MIN'])/2

                energy_mask = np.logical_and(energy_means>0.5, energy_means<10)
        
                fig, axs  = plt.subplots(1, 2, figsize=(8, 4))
                axs[0].scatter(energy_means[energy_mask], energy_counts[energy_mask])
                #axs[0].plot(energy_means[energy_mask], savgol_filter(energy_counts[energy_mask], 25, 3, mode='nearest'), color='red')
                axs[0].set(xlabel='Channel', ylabel='Counts', title='NICER Energy Spectrum', xscale='log')

                axs[1].scatter(channel_hz, rms_squared)
                axs[1].plot(channel_hz, savgol_filter(rms_squared, 4, 3, mode='nearest'), color='red')
                #lowess_fit = lowess(rms_squared, channel_hz, frac=1/10).T
                #axs[1].plot(lowess_fit[0], lowess_fit[1], color='green')
                axs[1].set(label='Index', ylabel='Power', title='Power Density Spectrum')

                plt.savefig(f'/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/mar2024/wk4/data-selection/images/{obsid}-{gti}.png', dpi=200)
                plt.close()

            else: 
                break