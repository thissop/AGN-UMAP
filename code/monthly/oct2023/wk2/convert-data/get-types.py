import pandas as pd
import os 
import numpy as np

for filename in os.listdir(data_directory):
    types.append(0) # FIX THIS! 
    csv_path = os.path.join(data_directory, filename)
    df = pd.read_csv(csv_path)
    wavelength = np.array(df['x'])
    flux = np.array(df['y'])