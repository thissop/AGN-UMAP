import matplotlib.pyplot as plt 
import pandas as pd
import numpy as np
import os
import pandas as pd
from scipy.interpolate import CubicSpline
from astropy.stats import sigma_clip
import numpy.ma as ma
import tensorflow as tf

from sklearn.metrics import accuracy_score, precision_score, recall_score
from sklearn.model_selection import train_test_split
from tensorflow.keras import layers, losses
from tensorflow.keras.datasets import fashion_mnist
from tensorflow.keras.models import Model

data_dir = '/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/oct2023/wk4/download-data/data'

dir = '/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/oct2023/wk1/bulk-first/data/processed_data'


fluxes = []
for f in os.listdir(dir): 
    filepath = os.path.join(dir, f)
    df = pd.read_csv(filepath, sep=' ')
    df.columns=['wave','flux']
    wave = df['wave']
    flux = df['flux']

    data = sigma_clip(np.array([wave, flux]), sigma=2, axis=0)
    
    wave = data[0]
    flux = data[1]
    
    cs = CubicSpline(wave, flux)

    x = np.linspace(3900, 9000, 1000)
    y = cs(x)

    df = pd.DataFrame()
    df['x'] = x
    df['y'] = y

    df.to_csv(f'/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/jan2024/wk2/process_data/data/{f}', index=False)



