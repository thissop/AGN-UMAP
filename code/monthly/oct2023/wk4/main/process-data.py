import pandas as pd
import numpy as np
import os 
from fantasy_agn.tools import read_sdss
from fantasy_agn.models import create_feii_model, create_model, create_tied_model, continuum, create_line, automatic_path
from scipy.interpolate import CubicSpline
import matplotlib.pyplot as plt

key = '/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/oct2023/wk1/bulk-first/list_of_spectra.csv'

df = pd.read_csv(key)
plates = df['PLATE']
mjds = df['MJD']
fiberids = df['FIBRID']
z_values = df['Z']

sum = 0
lower, upper = (2500, 9000)

# Fix N based on mean! 

n = int((upper-lower)/5)
x = np.linspace(lower, upper, n)
data_dir = '/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/oct2023/wk4/download-data/data'
for file in os.listdir(data_dir):

    data_path = os.path.join(data_dir, file)
    
    s = read_sdss(data_path)
    print(max(s.wave))
    #s.path = ''
    s.CorRed()
    s.crop(lower, upper)
    flux = s.flux
    wave = s.wave

    cont = continuum(s,min_refer=5350, refer=5550, max_refer=5650,min_index1=-3.7, max_index1=1,max_index2=3)
    broad = create_model(['hydrogen.csv', 'helium.csv'], prefix='br', fwhm=2000,min_fwhm=1000)
    narrow = create_tied_model(name='OIII5007',files=['narrow_basic.csv','hydrogen.csv', 'helium.csv'],prefix='nr',min_amplitude=0, fwhm=300,min_offset=-300, max_offset=300, min_fwhm=10, max_fwhm=1000)
    outOIII5007 = create_line(name="outOIII5007",pos=5006.803341,fwhm=1000,ampl=10,min_fwhm=1000,max_fwhm=1800,offset=0,min_offset=-3000,max_offset=0)
    outOIII4958 = create_line("outOIII4958",pos=4958.896072,fwhm=outOIII5007.fwhm,ampl=outOIII5007.ampl / 3.0, offset=outOIII5007.offs_kms)
    fe = create_feii_model(max_fwhm=6000) # when asking, how many/which species we should fit for? what values? her expertise // Also, how to deal with winds (separate from geo of expansion, but similiar manifestation)
    out = outOIII5007+outOIII4958
    model = cont+narrow+broad+fe+out # is red shift measuring technique bias? cheap/lazy is photo z. something to look into! incorporate red shift uncertainty. 

    # Save Imputed Data

    y = model(x) # norm this to 0-1 (later)! --> ask markus
    print(y)
    plt.scatter(wave, flux, s=2)
    plt.plot(x,y, color='orange')
    plt.show()
    plt.clf()
    plt.close()