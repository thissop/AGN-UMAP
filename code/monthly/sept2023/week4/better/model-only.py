#Before starting, we call some of the standard python packages, such as matplotlib, pandas, numpy, etc.

import matplotlib.pyplot as plt
import matplotlib as mpl
from matplotlib.ticker import (MultipleLocator, FormatStrFormatter, AutoMinorLocator)

from natsort import natsorted

import numpy as np
import pandas as pd

import glob

import json
from multiprocessing import Pool, cpu_count
plt.style.use('seaborn-talk')

# Below command import the necessary commands for preprocessing and fitting of spectra

from fantasy_agn.tools import read_sdss, read_text, read_gama_fits

from fantasy_agn.models import create_input_folder, automatic_path

from fantasy_agn.models import create_feii_model, create_model, create_tied_model, continuum, create_line, create_fixed_model


filenames = ['spec-11277-58450-0294.fits','spec-11277-58450-0300.fits',
             'spec-11277-58450-0313.fits','spec-11277-58450-0699.fits',
             'spec-11277-58450-0705.fits','spec-11277-58450-0708.fits',
             'spec-11277-58450-0712.fits','spec-11277-58450-0720.fits']

data_dir = 'data/190SDSSspec/'

s=read_sdss(f'{data_dir}{filenames[0]}') # very convienient...was having problems tbh. 
s.err=np.abs(s.err) #make sure that all errors are positive
#s.DeRedden()
s.CorRed()
s.fit_host_sdss()
#plt.title(s.name.split('/')[-1].split('.')[0])
#plt.savefig(s.name+'_host.pdf')

# crops a spectrum, and creates automatic path of the input line lists
s.crop(3000,7000)
automatic_path(s)

# defines fitting model
cont=continuum(s,min_refer=5350, refer=5550, max_refer=5650,min_index1=-3.7, max_index1=1,max_index2=3)
broad=create_model(['hydrogen.csv', 'helium.csv'], prefix='br', fwhm=2000,min_fwhm=1000)
narrow=create_tied_model(name='OIII5007',files=['narrow_basic.csv','hydrogen.csv', 'helium.csv'],prefix='nr',min_amplitude=0, fwhm=300,min_offset=-300, max_offset=300, min_fwhm=10, max_fwhm=1000)
outOIII5007=create_line(name="outOIII5007",pos=5006.803341,fwhm=1000,ampl=10,min_fwhm=1000,max_fwhm=1800,offset=0,min_offset=-3000,max_offset=0)
outOIII4958 = create_line("outOIII4958",pos=4958.896072,fwhm=outOIII5007.fwhm,ampl=outOIII5007.ampl / 3.0, offset=outOIII5007.offs_kms)
fe=create_feii_model(max_fwhm=6000)
out=outOIII5007+outOIII4958
model =cont+narrow+broad+fe+out

import time 

start = time.time()

s.fit(model, ntrial=5)

print(time.time()-start)

quit()

plt.style.context(['nature', 'notebook'])
plt.figure(figsize=(18,8))
plt.plot(s.wave, s.flux, color="#929591", label='Obs', lw=2)
plt.plot(s.wave, model(s.wave), color="#F10C45",label='Model',lw=3)
#plt.plot(s.wave, model(s.wave)-s.flux-70, '-',color="#929591", label='Residual', lw=2)
#plt.axhline(y=-70, color='deepskyblue', linestyle='--', lw=2)

plt.plot(s.wave, cont(s.wave),'--',color="#042E60",label='Continuum', lw=3)
plt.plot(s.wave, narrow(s.wave),label='Narrow',color="#25A36F",lw=3)
plt.plot(s.wave, broad(s.wave), label='Broad H', lw=3, color="#2E5A88")
plt.plot(s.wave, fe(s.wave),'-',color="#CB416B",label='Fe II model', lw=3)

plt.xlabel('Rest Wavelength (Å)',fontsize=20)
plt.ylabel('Flux',fontsize=20)
plt.xlim(3000,np.max(s.wave))
#plt.ylim(-150,900)
plt.tick_params(which='both', direction="in")
plt.yticks(fontsize=20)
plt.xticks(np.arange(4000, np.max(s.wave), step=500),fontsize=20)
plt.legend(loc='upper center',  prop={'size': 22}, frameon=False, ncol=2)

plt.savefig('code/monthly/sept2023/week4/better/model-data.png', dpi=250)

## MONTE CARLO 

d={'wave':s.wave,'flux':s.flux,'error':s.err,'model':model(s.wave),'cont':cont(s.wave), 'narrow':narrow(s.wave), 'broad':broad(s.wave), 'fe':fe(s.wave),'out':out(s.wave)}

df=pd.DataFrame(d)
df.to_csv(s.name+'_model.csv')

dicte=zip(s.gres.parnames, s.gres.parvals)
res=dict(dicte)
res['redshift']= float(s.z)
res['RA']=float(s.ra)
res['dec']=float(s.dec)
res['fiber']=str(s.fiber)
res['mjd']=float(s.mjd)
res['plate']=str(s.plate)

# creates a file to save the fitting results of the original spectra
with open(s.name+'_pars.json', 'w') as fp:
                json.dump(res, fp)
print('beginning monte')
# creates N=500 mock spectra, fits the same model, and write the fitting results.
s.monte_carlo(nsample=50)
print("mcmc ok")
