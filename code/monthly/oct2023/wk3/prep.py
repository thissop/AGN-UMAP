import pandas as pd
import numpy as np
import os 
from fantasy_agn.tools import read_text
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
lower, upper = (3000, 4000)
n = int((upper-lower)/5)
x = np.linspace(lower, upper, n)

sum_n = 0
sum_u = 0

for plate, mjd, fiberid, z in zip(plates, mjds, fiberids, z_values):
    fiberid = (4-len(str(fiberid)))*'0'+str(fiberid)
    string = f'{plate}-{mjd}-{fiberid}'
    data_path = f'code/monthly/oct2023/wk1/bulk-first/data/processed_data/spec-{string}.csv'
    if os.path.exists(data_path): 
        s = read_text(data_path)

        #s.path = ''
        s.CorRed(redshift=z)
        s.crop(lower, upper)
        flux = s.flux
        wave = s.wave
        if len(wave)>0 and np.max(wave)>3900:
        #if np.max(flux)>7000: #len(flux)>n:
            sum_n += 1
            if True: #max(wave)>upper-50: 
                sum_u += 1
                # Fit Cubic Model
                max_flux = np.max(flux)
                min_flux = np.min(flux)

                cs = CubicSpline(wave, flux)
                y_cubic = cs(x)
                y_cubic = (y_cubic-min_flux)/(max_flux-min_flux) # do this as alternative, then do outliers removal? estimate via neighbors?

                # Interpolate with Model
                '''
                automatic_path(s, path_to_models='code/monthly/oct2023/wk3/models')

                cont = continuum(s, min_refer=5350, refer=5550, max_refer=5650,min_index1=-3.7, max_index1=1,max_index2=3)
                broad = create_model(['hydrogen.csv', 'helium.csv'], prefix='br', fwhm=2000,min_fwhm=1000)
                narrow = create_tied_model(name='OIII5007',files=['narrow_basic.csv','hydrogen.csv', 'helium.csv'],prefix='nr',min_amplitude=0, fwhm=300,min_offset=-300, max_offset=300, min_fwhm=10, max_fwhm=1000)
                outOIII5007 = create_line(name="outOIII5007",pos=5006.803341,fwhm=1000,ampl=10,min_fwhm=1000,max_fwhm=1800,offset=0,min_offset=-3000,max_offset=0)
                outOIII4958 = create_line("outOIII4958",pos=4958.896072,fwhm=outOIII5007.fwhm,ampl=outOIII5007.ampl / 3.0, offset=outOIII5007.offs_kms)
                fe = create_feii_model(max_fwhm=6000) # when asking, how many/which species we should fit for? what values? her expertise // Also, how to deal with winds (separate from geo of expansion, but similiar manifestation)
                out = outOIII5007+outOIII4958
                model = cont+narrow+broad+fe+out # is red shift measuring technique bias? cheap/lazy is photo z. something to look into! incorporate red shift uncertainty. 
                y_model = model(x)
                '''
                # Plot Data and Models

                fig, axs = plt.subplots(2, 1)
                axs[0].plot(x, y_cubic, label='cubic interp', lw=2, color='red')
                flux_ = (flux-min_flux)/(max_flux-min_flux)
                axs[0].scatter(wave, flux_, label='real', s=3)
                axs[0].set(xlabel='wavelength', ylabel='flux')#, xlim=(4000,5000))
                axs[0].legend()

                #axs[1].plot(x, y_model, label='model interp')
                #axs[1].scatter(wave, flux/np.max(flux), label='real')
                #axs[1].set(xlabel='wavelength', ylabel='flux', xlim=(4000,5000))
                #axs[1].legend()

                fig.tight_layout()
                plt.savefig(f'code/monthly/oct2023/wk3/plots/data-processing/cubic/{string}.png')
                plt.clf()
                plt.close()

                df = pd.DataFrame()
                df['x'] = x
                df['y_cubic'] = y_cubic
                #df['y_model'] = y_model
                #df['wave'] = wave
                #df['flux'] = flux
                df.to_csv(f'code/monthly/oct2023/wk3/data/{string}.csv', index=False)

            else: 
                s = read_text(data_path)
                wave, flux = s.wave, s.flux
                print(len(flux))

                fig, axs = plt.subplots(2,1)
                axs[0].scatter(wave, flux, s=2)

                axs[1].scatter(wave, flux, s=2)

                axs[1].set(xlim=(4500, 5500))
                
                fig.tight_layout()
                plt.savefig(f'code/monthly/oct2023/wk3/plots/temp/{string}.png')
                plt.clf()
                plt.close()

        else: 
            try:
                print(np.max(wave))
            except: 
                continue 
print(sum_n, sum_u)