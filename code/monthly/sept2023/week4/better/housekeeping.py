def check_ranges(d):
    from fantasy_agn.tools import read_sdss
    import os 
    import matplotlib.pyplot as plt 
    import numpy as np

    mins = []
    maxs = []
    for i in os.listdir(d):
        full_path = os.path.join(d, i)

        s=read_sdss(full_path) # very convienient...was having problems tbh. 

        wav = s.wave
        mins.append(np.min(wav))
        maxs.append(np.max(wav))

    ranges = np.array(maxs)-np.array(mins)

    fig, axs = plt.subplots(1, 3)

    names = ['Min', 'Max', 'Range']
    for i, arr in enumerate([mins, maxs, ranges]): 
        ax = axs[i]
        ax.hist(arr)
        ax.set(xlabel=names[i])

    axs[0]


