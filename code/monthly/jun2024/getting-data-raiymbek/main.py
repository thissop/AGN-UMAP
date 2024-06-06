import pandas as pd
from astropy.io import fits 
import os 
import numpy as np
import matplotlib.pyplot as plt 
import smplotlib
from tqdm import tqdm 
from scipy import interpolate

def download_file(url, filepath):
    import requests

    response = requests.get(url, stream=True)
    if response.status_code == 200:
        with open(filepath, 'wb') as file:
            for chunk in response.iter_content(chunk_size=8192):
                file.write(chunk)

key_df = pd.read_csv('/Users/tkiker/Documents/GitHub/AGN-UMAP/code/monthly/jun2024/getting-data-raiymbek/data/[QPO][binary].csv')
obsids = key_df[key_df['class'] == 1]['observation_ID'].values

for obsid in tqdm(obsids): 
    energy_url = f'https://github.com/thissop/MAXI-J1535/raw/main/final-push/data/sources/MAXI_J1535-571/raw_spectral/{obsid}.csv'  
    energy_path = f'/Users/tkiker/Documents/GitHub/AGN-UMAP/code/monthly/jun2024/getting-data-raiymbek/data/energy/{obsid}-energy.csv'

    #download_file(energy_url, energy_path)

    qpo_dir = f'/Users/tkiker/Documents/GitHub/AGN-UMAP/code/monthly/jun2024/getting-data-raiymbek/data/raw-pds/{obsid}'
    
    if not os.path.exists(qpo_dir):
        os.mkdir(qpo_dir)

    name_list = obsid.split('_')

    obs = name_list[0]
    gti = name_list[1]

    pds_url = f'https://github.com/thissop/MAXI-J1535/raw/main/final-push/data/sources/MAXI_J1535-571/regression/qpo/jspipe_qpo/{obs}/js_ni{obs}_0mpu7_silver_GTI{gti}-bin.pds'
    pds_path = os.path.join(qpo_dir, f'{obsid}-bin.pds')

    #download_file(pds_url, pds_path)

    rsp_url = f'https://github.com/thissop/MAXI-J1535/raw/main/final-push/data/sources/MAXI_J1535-571/regression/qpo/jspipe_qpo/{obs}/js_ni{obs}_0mpu7_silver_GTI{gti}-fak.rsp'
    rsp_path = os.path.join(qpo_dir, f'{obsid}-fak.rsp')

    #download_file(rsp_url, rsp_path)

    pds_hdul = fits.open(pds_path)
    pds_data = np.array(pds_hdul[1].data)
    rms_squared = np.array([arr[1] for arr in pds_data])

    rsp_hdul = fits.open(rsp_path)
    rsp_data = np.array(rsp_hdul[1].data)
    channel_widths = np.array([arr[2]-arr[1] for arr in rsp_data])
    channel_hz = np.array([(arr[2]+arr[1])/2 for arr in rsp_data])

    rms_squared = rms_squared/channel_widths

    #mask = np.logical_and(channel_hz>2, channel_hz<=10)

    #channel_hz = channel_hz[mask] # hz mid point for pds 
    #rms_squared = rms_squared[mask] # data are in rms^2/channel width

    x = np.linspace(2.1, 10, 60)
    y = np.interp(x, channel_hz, rms_squared)

    qpo_df = pd.DataFrame()
    
    qpo_df['Frequency'] = x
    qpo_df['Power'] = y

    qpo_df.to_csv(f'/Users/tkiker/Documents/GitHub/AGN-UMAP/code/monthly/jun2024/getting-data-raiymbek/data/pds/{obsid}-pds.csv', index=False)

    # Get Energy File

    fig, axs = plt.subplots(1, 2, figsize=(6, 3))

    energy_df = pd.read_csv(energy_path)
    axs[0].plot(energy_df['CHANNEL'], energy_df['COUNTS'])
    axs[0].set(xlabel='Channel', ylabel='Energy')

    axs[1].plot(x, y)
    axs[1].set(xlabel='Frequency (Hz)', ylabel='Power')

    plt.tight_layout()

    plot_dir = '/Users/tkiker/Documents/GitHub/AGN-UMAP/code/monthly/jun2024/getting-data-raiymbek/plots'
    plt.savefig(os.path.join(plot_dir, f'{obsid}.png'))
    plt.clf()
    plt.close()
