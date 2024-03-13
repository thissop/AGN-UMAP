def download(plate, fiber, mjd, ra, dec):           
    import matplotlib.pyplot as plt 
    import urllib.request
    from astropy.io import fits

    sdss_link = f'https://dr18.sdss.org/optical/spectrum/view/data/format%3Dfits/spec%3Dlite?plateid={plate}&mjd={mjd}&fiberid={fiber}'
    sdss_file = f'/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/oct2023/wk4/download-data/data/spSpec-{plate}-{mjd}-{fiber}.fits'
    plot_path = f'/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/oct2023/wk4/download-data/plots/spectra/spSpec-{plate}-{mjd}-{fiber}.png'
    im_path = f'/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/oct2023/wk4/download-data/plots/skyplot/spSpec-{plate}-{mjd}-{fiber}.png'

    im_url = f'https://skyserver.sdss.org/dr18/SkyServerWS/ImgCutout/getjpeg?TaskName=Skyserver.Explore.Image&ra={ra}%20&dec={dec}&scale=0.2&width=200&height=200&opt=G'

    urllib.request.urlretrieve(sdss_link, sdss_file)
    urllib.request.urlretrieve(im_url, im_path)

    data = fits.open(sdss_file)
    wave = 10 ** data[1].data['loglam']  # OBS wavelength [A]
    flux = data[1].data['flux']  # OBS flux [erg/s/cm^2/A]

    fig, ax = plt.subplots()

    ax.plot(wave, flux)
    ax.set(xlabel='wavelength', ylabel='flux')
    plt.savefig(plot_path)
    plt.close()
    plt.clf()

def main(input_dir:str='/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/oct2023/wk4/download-data/data/',
         output_dir:str='/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/nov2023/wk1/qsofitmore/output/', 
         key:str='/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/nov2023/wk1/qsofitmore/list_of_spectra.csv'): 

    from qsofitmore import QSOFitNew
    #import pyqsofit
    #from pyqsofit.PyQSOFit import QSOFit
    import numpy as np
    import matplotlib.pyplot as plt
    import pandas as pd
    from astropy.table import Table
    from astropy.io import fits
    import os 
    from tqdm import tqdm
    import time 

    key = pd.read_csv(key)

    plot_dir = os.path.join(output_dir, 'plots')
    if not os.path.exists(plot_dir):
        os.mkdir(plot_dir)

    processed_data_dir = os.path.join(output_dir, 'processed_data')
    if not os.path.exists(processed_data_dir): 
        os.mkdir(processed_data_dir)

    def fit_spectra(data_path, z, ra, dec, 
                    output_path:str=output_dir): 
        
        name = data_path.split('/')[-1].split('.')[0]
        processed_data_path = os.path.join(processed_data_dir, f'{name}.csv')
        if not os.path.exists(processed_data_path):
            data = fits.open(data_path)
            wave = 10 ** data[1].data['loglam']  # OBS wavelength [A]
            flux = data[1].data['flux']  # OBS flux [erg/s/cm^2/A]
            err = np.nan_to_num(1 / np.sqrt(data[1].data['ivar']), nan=0.0)  # 1 sigma error
            z = data[2].data['z'][0]  # Redshift

            q = QSOFitNew.QSOFit(lam=wave, flux=flux, err=err, 
                        z=z, ra=ra, dec=dec,
                        name=name, is_sdss=True, path=output_path)

            q.setmapname("sfd")
            
            q.Fit(name = name, deredden = True, wave_range = None, wave_mask =None,
                decomposition_host = True, Mi = None, npca_gal = 5, npca_qso = 20,
                Fe_uv_op = True, poly = True, BC = False, MC = True, n_trails = 20,
                linefit = True, tie_lambda = True, tie_width = True,
                tie_flux_1 = True, tie_flux_2 = True, save_result = True,
                plot_fig = True, save_fig = True, plot_line_name = True,
                plot_legend = True) # The broad_fwhm parameter can be adjusted depending on your definition (default is 1200 km s

            wave = q.wave_prereduced
            print('\n\nchecking min max\n\n')
            if min(wave)<=1501 and max(wave)>=2999:
                print('\n\nmin max is good\n\n')
                x = np.linspace(1500, 3000, 1500)
                fitted_df = pd.DataFrame()
                fitted_df['x'] = x
                fitted_df['flux'] = np.interp(x, wave, q.flux_prereduced)
                fitted_df['continuum'] = np.interp(x, wave, q.f_conti_model)
                fitted_df['model'] = np.interp(x, wave, q.lines_total)

                fitted_df.to_csv(processed_data_path, index=False)

    key = key.sample(frac=1)
    plates, mjds, fibers, zs, ras, decs = [key[i] for i in ['PLATE','MJD','FIBRID', 'Z', 'RA','DEC']]
    for plate, mjd, fiber, z, ra, dec in tqdm(zip(plates, mjds, fibers, zs, ras, decs)):
        fits_path = f'{input_dir}/spSpec-{plate}-{mjd}-{fiber}.fits'

        if os.path.exists(fits_path):

            continue 

            try: 
                fit_spectra(fits_path, z=z, ra=ra, dec=dec)
            except Exception as e: 
                print(e)
                continue 
        else: 
            
            download(plate, fiber, mjd, ra, dec) 
            if os.path.exists(fits_path):
                fit_spectra(fits_path, z=z, ra=ra, dec=dec) 
            else: 
                raise Exception('did not exist, tried to download, did not work') 
            
main()