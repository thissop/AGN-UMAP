def fit_data(data_dir:str='/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/oct2023/wk4/download-data/data',
             save_dir:str='/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/oct2023/wk4/qsofit/model-fits',
             plot_dir:str='/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/oct2023/wk4/qsofit/plots',
             qsofit_directory:str='/Users/yaroslav/Documents/2. work/Research/GitHub/PyQSOFit/'): 
    
    r'''
    Arguments
    ---------

    data_dir: string directory to directory of fits SDSS spectra files 
    save_dir: string for directory into which processed data should be saved
    plot_dir: directory to save plots in 
    qsofit_directory: path to PyQSOFit folder (that you cloned from GitHub to set up the library) 
    '''

    import pandas as pd
    import numpy as np 
    import os 
    from astropy.io import fits
    import time
    from pyqsofit.PyQSOFit import QSOFit
    import matplotlib.pyplot as plt 

    for file in os.listdir(data_dir):
        object_name = file.split('.')[0]
        file = os.path.join(data_dir, file)

        data = fits.open(file)
        wave = 10 ** data[1].data['loglam']  # OBS wavelength [A]
        flux = data[1].data['flux']  # OBS flux [erg/s/cm^2/A]
        err = np.nan_to_num(1 / np.sqrt(data[1].data['ivar']), nan=0.0)  # 1 sigma error
        z = data[2].data['z'][0]  # Redshift

        plt.plot(wave, flux)
        plt.show()
        plt.clf()
        plt.close()

        print(wave.shape)
        print(flux.shape)
        print(err.shape)
        print(z)
        #quit()

        # Prepare data
        q_mle = QSOFit(wave, flux, err, z, path=qsofit_directory)
        start = time.time()
        print(file.split('/')[-1])
        q_mle.Fit(plot_fig=False,save_fig=False, kwargs_plot={'save_fig_path':'.','broad_fwhm':1200})
        # broad_fwhm =  # km/s, lower limit that code decide if a line component belongs to broad component

        end = time.time()
        print(f'Fitting finished in {np.round(end - start, 1)}s')

        fig, ax = plt.subplots(figsize=(15, 5))
        ax.scatter(q_mle.wave, q_mle.flux, s=2, color='#408ee0')
        ax.plot(q_mle.wave, q_mle.Manygauss(np.log(q_mle.wave), q_mle.gauss_result) + q_mle.f_conti_model, label='Line', lw=2, color='#e05f40')
        plt.legend()
        ax.set_xlabel(r'$\rm Rest \, Wavelength$ ($\rm \AA$)', fontsize=20)
        ax.set_ylabel(r'$\rm f_{\lambda}$ ($\rm 10^{-17} erg\;s^{-1}\;cm^{-2}\;\AA^{-1}$)', fontsize=20)
        plt.savefig(os.path.join(plot_dir, f'{object_name}.png'))
        plt.clf()
        plt.close()
        #ax.plot(q_mle.wave, q_mle.f_conti_model, 'c', lw=2, label='Continuum+FeII')#ax.plot(q_mle.wave, q_mle.PL_poly_BC, 'orange', lw=2, label='Continuum')#ax.plot(q_mle.wave, q_mle.host, 'm', lw=2, label='Host')#ax.plot(q_mle.wave, gauss_result+q_mle.f_conti_model, label='Total Model')

        # Save Data
        df = pd.DataFrame() 
        df['wave'] = q_mle.wave 
        df['flux'] = q_mle.flux 

        df.to_csv(os.path.join(save_dir, f'{object_name}.csv'), index=False)

fit_data()