# 11279 58449  74 
# 11279 58449 956 
# 11279 58449 978

import os

def prep_data(data_file:str, lower:int=3000, upper:int=7000,
              plot_dir:str='code/monthly/oct2023/wk1/bulk-first/plots'): 
    
    import matplotlib.pyplot as plt
    import numpy as np
    import pandas as pd
    from fantasy_agn.tools import read_text, read_sdss
    from fantasy_agn.models import create_feii_model, create_model, create_tied_model, continuum, create_line
    from astropy.io import fits 

    file_name = data_file.split('/')[-1]
    host_name = file_name.split('.')[0]
    file_info = data_file.split('.')[0].split('/')

    s=read_sdss(data_file) # issues here recently? why??
    
    wave = s.wave 
    flux = s.flux
    
    s.CorRed() # --> highlight for dr. steiner
    plt.title(s.name.split('/')[-1].split('.')[0])
    plt.savefig(f'{plot_dir}/{host_name}_data_only.png')
    plt.clf()
    plt.close()

    # Define Model
    cont = continuum(s,min_refer=5350, refer=5550, max_refer=5650,min_index1=-3.7, max_index1=1,max_index2=3)
    
    broad = create_model(['hydrogen.csv', 'helium.csv'], prefix='br', fwhm=2000,min_fwhm=1000)
    narrow = create_tied_model(name='OIII5007',files=['narrow_basic.csv','hydrogen.csv', 'helium.csv'],prefix='nr',min_amplitude=0, fwhm=300,min_offset=-300, max_offset=300, min_fwhm=10, max_fwhm=1000)
    outOIII5007 = create_line(name="outOIII5007",pos=5006.803341,fwhm=1000,ampl=10,min_fwhm=1000,max_fwhm=1800,offset=0,min_offset=-3000,max_offset=0)
    outOIII4958 = create_line("outOIII4958",pos=4958.896072,fwhm=outOIII5007.fwhm,ampl=outOIII5007.ampl / 3.0, offset=outOIII5007.offs_kms)
    fe = create_feii_model(max_fwhm=6000) # when asking, how many/which species we should fit for? what values? her expertise // Also, how to deal with winds (separate from geo of expansion, but similiar manifestation)
    out = outOIII5007+outOIII4958
    model = cont+narrow+broad+fe+out # is red shift measuring technique bias? cheap/lazy is photo z. something to look into! incorporate red shift uncertainty. 
    # Save Imputed Data

    x = np.linspace(lower, upper, 1000) # REVISE ONCE IT GETS FIT! ASK?
    y = model(x) # norm this to 0-1 (later)! --> ask markus

    plt.scatter(wave, flux)
    plt.plot(x,y)
    plt.xlim(lower, upper)
    plt.show()

prep_data('/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/oct2023/wk4/download-data/data/spSpec-11277-58450-294.fits')

#PLATE,MJD,FIBRID,SDSS_NAME,RA,DEC,Z,SOURCE,Z_PIPE,ZWARNING,EXTINCTION,SN_MEDIAN_ALL
#11546,58488,91,000010.98+102200.4,0.045754051,10.366789,1.7331870,PIPE,1.7331870,0,0.366186,4.2038808
