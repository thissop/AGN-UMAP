import spender
import torch
from accelerate import Accelerator
import pandas as pd 
import numpy as np
from tqdm import tqdm
import time 

# Hardware optimization
accelerator = Accelerator(mixed_precision='fp16')

# Get code, instrument, and pretrained spectrum model from the hub
sdss, model = spender.hub.load('sdss_II', map_location=accelerator.device)

# Move the model to the accelerator device (CUDA)
model.to(accelerator.device)

# Get some SDSS spectra from the ids, store locally in data_path
data_path = "./DATA"

# Correct the ids to be a list of tuples

key_df = pd.read_csv(r'C:\Users\tkiker\Documents\GitHub\AGN-UMAP\code\monthly\july2024\wk1\top_10000_agn.csv')

downloaded_ids = []

key_df = key_df.sort_values(by='plate')

print(key_df)

ids = np.array([key_df['plate'], key_df['mjd'], key_df['fiberID']]).T
ids = [tuple(i) for i in ids]

for id in tqdm(ids):
    if len(downloaded_ids) < 500: 
        id_list = [id]
        
        try: 
            spec, w, z, norm, zerr = sdss.make_batch(data_path, id_list)
            downloaded_ids.append(id)
        
        except Exception as e: 
            print(e)
            continue
    
    else:
        break  

key_df = pd.DataFrame()
key_df['downloaded_id'] = downloaded_ids

key_df.to_csv(r'C:\Users\tkiker\Documents\GitHub\AGN-UMAP\code\monthly\july2024\wk1\downloaded_ids.csv', index=False)