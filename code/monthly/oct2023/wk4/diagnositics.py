import pandas as pd
import numpy as np
import os 
from fantasy_agn.tools import read_text
import matplotlib.pyplot as plt
from scipy.optimize import minimize



def bounds(): 
    key = '/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/oct2023/wk1/bulk-first/list_of_spectra.csv'

    df = pd.read_csv(key)
    plates = df['PLATE']
    mjds = df['MJD']
    fiberids = df['FIBRID']
    z_values = df['Z']

    sum = 0
    lower, upper = (3000, 4000)
    n = int((upper-lower)/5)
    x = np.linspace(lower, upper, n)

    sum_n = 0
    sum_u = 0

    starts = []
    ends  = []

    for plate, mjd, fiberid, z in zip(plates, mjds, fiberids, z_values):
        fiberid = (4-len(str(fiberid)))*'0'+str(fiberid)
        string = f'{plate}-{mjd}-{fiberid}'
        data_path = f'code/monthly/oct2023/wk1/bulk-first/data/processed_data/spec-{string}.csv'
        if os.path.exists(data_path): 
            s = read_text(data_path)

            #s.path = ''
            s.CorRed(redshift=z)
            flux = s.flux
            wave = s.wave

            if len(wave) > 0: 
                starts.append(np.min(wave))
                ends.append(np.max(wave))

    fig, axs = plt.subplots(2,2, figsize=(6,6))

    axs[0,0].hist(starts)
    axs[0,0].set(xlabel='All Start')

    axs[0,1].hist(ends)
    axs[0,1].set(ylabel='All End')

    starts = np.array(starts)
    ends = np.array(ends)

    lower_bound_mask = np.logical_and(starts>1000, starts<1010)
    axs[1,0].hist(starts[lower_bound_mask])
    axs[1,0].set(xlabel='start', ylabel='>1000')
    axs[1,1].hist(ends[lower_bound_mask])
    axs[1,1].set(xlabel='ends')
    plt.show()

    def score_function(cutoffs, min_x_values, max_y_values):
        lower_cutoff_x, upper_cutoff_y = cutoffs
        score = 0

        for min_x, max_y in zip(min_x_values, max_y_values):
            if min_x <= lower_cutoff_x and max_y >= upper_cutoff_y:
                score += 1

        return -score  # We want to maximize the number of matching files, so we negate the score.

    #result = minimize(score_function, (1000, 4000), args=(starts, ends), method='Nelder-Mead')

    #optimal_cutoffs = result.x
    #print(optimal_cutoffs)

    #print(score_function(cutoffs=(1000,5000), min_x_values=starts, max_y_values=ends))
    #print(score_function(cutoffs=(1000,4000), min_x_values=starts, max_y_values=ends))
