# 11279 58449  74 
# 11279 58449 956 
# 11279 58449 978

import os

def prep_data(data_file:str, lower:int=3000, upper:int=7000,
              out_dir:str='code/monthly/oct2023/wk1/bulk-first/processed_data',
              plot_dir:str='code/monthly/oct2023/wk1/bulk-first/plots'): 
    
    import matplotlib.pyplot as plt
    import numpy as np
    import pandas as pd
    from fantasy_agn.tools import read_sdss
    from fantasy_agn.models import create_feii_model, create_model, create_tied_model, continuum, create_line

    file_name = data_file.split('/')[-1]
    host_name = file_name.split('.')[0]
    file_info = data_file.split('.')[0].split('/')

    s=read_sdss(data_file) # issues here recently? why??
    s.err=np.abs(s.err) 
    #s.DeRedden()
    s.CorRed() # --> highlight for dr. steiner
    s.fit_host_sdss()
    s.crop(lower, upper)
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
    # get errors, get differences between inputed points and the real ones. 

    df = pd.DataFrame(d={'wavelength':x, 'flux':y})
    df.to_csv(f'{out_dir}/{host_name}.csv', index=False)

    # Plot Model

    plt.style.context(['nature', 'notebook'])
    plt.figure(figsize=(18,8))
    plt.plot(s.wave, s.flux, color="#929591", label='Obs', lw=2)
    plt.plot(s.wave, model(s.wave), color="#F10C45",label='Model',lw=3)
    plt.plot(x, y, color="#929591", label='Inputed x/y', lw=3)
    #plt.plot(s.wave, model(s.wave)-s.flux-70, '-',color="#929591", label='Residual', lw=2)
    #plt.axhline(y=-70, color='deepskyblue', linestyle='--', lw=2)

    plt.plot(s.wave, cont(s.wave),'--',color="#042E60",label='Continuum', lw=3)
    plt.plot(s.wave, narrow(s.wave),label='Narrow',color="#25A36F",lw=3)
    plt.plot(s.wave, broad(s.wave), label='Broad H', lw=3, color="#2E5A88")
    plt.plot(s.wave, fe(s.wave),'-',color="#CB416B",label='Fe II model', lw=3)

    plt.xlabel('Rest Wavelength (Å)',fontsize=20)
    plt.ylabel('Flux',fontsize=20)
    plt.xlim(lower, upper)
    #plt.ylim(-150,900)
    plt.tick_params(which='both', direction="in")
    plt.yticks(fontsize=20)
    plt.xticks(np.arange(4000, np.max(s.wave), step=500),fontsize=20)
    plt.legend(loc='upper center',  prop={'size': 22}, frameon=False, ncol=2)

    plt.savefig(f'{plot_dir}/model-data.png', dpi=250)

data_dir = 'data/190SDSSspec'

for data_file in os.listdir(data_dir): 
    if data_file.split('.')[-1] == 'fits':
        prep_data(data_file=f'{data_dir}/{data_file}')