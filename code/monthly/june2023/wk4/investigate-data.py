import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt 

d = 'data/Kuraszkiewicz2004AGNSpectra'
lens = []
mins = []
maxs = []
for f in os.listdir(d):
    df = pd.read_csv(os.path.join(d,f))
    wavs = np.array(df['Wavelength (Ang)'])
    lens.append(len(wavs))
    mins.append(min(wavs))
    maxs.append(max(wavs))

for i in (lens, mins, maxs):
    print(np.sort(list(set(i))))
    print(np.argmax(lens), np.argmax(maxs), np.argmin(mins))