#Before starting, we call some of the standard python packages, such as matplotlib, pandas, numpy, etc.

import matplotlib.pyplot as plt
import matplotlib as mpl
from matplotlib.ticker import (MultipleLocator, FormatStrFormatter, AutoMinorLocator)

import numpy as np
import pandas as pd

from fantasy_agn.tools import read_sdss

plt.style.use('seaborn-talk')

## PLOT
filenames = ['spec-11277-58450-0294.fits','spec-11277-58450-0300.fits',
             'spec-11277-58450-0313.fits','spec-11277-58450-0699.fits',
             'spec-11277-58450-0705.fits','spec-11277-58450-0708.fits',
             'spec-11277-58450-0712.fits','spec-11277-58450-0720.fits']

data_dir = 'data/190SDSSspec/'

s=read_sdss(f'{data_dir}{filenames[0]}') # very convienient...was having problems tbh. 

file = s.name+'_model.csv'

df=pd.read_csv(file)

fig, ax =plt.subplots(figsize=(12,8))

plt.plot(df.wave, df.flux, '-', color="#929591", label='Obs', lw=2)
plt.plot(df.wave, df.model, '-', color="#F10C45", label='Model', lw=2)

plt.plot(df.wave, df.cont, '-', color="#042E60", label='Cont.', lw=2)
plt.plot(df.wave, df.narrow, '-', color='#25A36F', label='Narrow',lw=2)
plt.plot(df.wave, df.broad, '-', color="#2E5A88",label='Broad H', lw=2)
plt.plot(df.wave, df.out, '--', color="orange",label='Outflow', lw=2)
plt.plot(df.wave, df.fe, '-', color='#A8B504', label='Fe II', lw=2) ##CB416B

try:
    plt.plot(df.wave, df.fe_forb, '-', color='xkcd:black', label='[Fe II]', lw=4)
except:
    pass

x_tics=np.linspace(4000,5600, 6)

plt.xticks(x_tics, fontsize=24)
plt.yticks(fontsize=24)
plt.tick_params(which='both', direction="in")

plt.ylim(0,df.model.max())
plt.xlim(4000,5600)
ax.xaxis.set_minor_locator(AutoMinorLocator())
ax.yaxis.set_minor_locator(AutoMinorLocator())

plt.legend(loc='upper center',  prop={'size': 24}, frameon=False, ncol=2)
plt.xlabel(r'Rest wavelength ($\rm{\AA}$)', fontsize=24)
plt.ylabel(r'$F_{\lambda}$ ($10^{-17}$ $\rm{erg s}^{-1}\rm{cm}^{-2}\rm{\AA}^{-1}$)', fontsize=24)

name=file.split('.')[0]+'.pdf'

plt.text(0.98, 0.98,name[:20],fontsize=20,ha='right', va='top',transform=ax.transAxes)

plt.tight_layout()
plt.savefig(name, dpi=300,bbox_inches='tight')

# posteriors 

data = pd.read_csv('data/190SDSSspec/spec-11277-58450-0294_pars.csv')
import corner

# Define the format of the panels
CORNER_KWARGS = dict(
    smooth=0.95,
    label_kwargs=dict(fontsize=16),
    title_kwargs=dict(fontsize=16),
    max_n_ticks=4,
    color="red",
    size=6,
    tick_param=dict(axis='both', labelsize=16),

)

# Select the columns you want to include in the corner plot
columns = ['feii.fwhm', 'br_HeI_3188.fwhm']

# Extract the selected columns from the data and define labels
selected_data = data[columns]
labels = ['FWHM Fe II [km/s]', 'FWHM He I [km/s]']

# Create the corner plot with axis labels, and range of values
corner_plot = corner.corner(selected_data, labels=labels, range=[(4500, 5500), (400,5000)],**CORNER_KWARGS)

for ax in corner_plot.get_axes():
    ax.tick_params(axis='both', labelsize=16)


# Display the plot
corner_plot.show()

