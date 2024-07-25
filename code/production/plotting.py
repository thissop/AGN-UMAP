def plot_spectrum(fits_path, rest_spectrum:bool=True, vlines:list=[2000, 2500]): 
    from astropy.io import fits 
    import matplotlib.pyplot as plt 
    import smplotlib 

    hdul = fits.open(fits_path)
    data = hdul[1].data

    wavelength = 10**data["loglam"]
    flux = data["flux"]

    specinfo = hdul[2].data[0]
    z = specinfo["Z"]

    if rest_spectrum: 
        wavelength/=(1+z)

    fig, ax = plt.subplots(figsize=(5, 2.5))

    ax.plot(wavelength, flux, label=f'z={str(round(z,2))}')

    if vlines is not None: 
        for i in vlines: 
            plt.axvline(x=i, color='red')
    
    ax.set_xlabel('Rest Wavelength')
    ax.set_ylabel('Best Fit Model Flux')
    ax.set_title(fits_path.split(r'spec-')[-1][:-5])
    ax.legend()

    fig.tight_layout()

    return fig, ax 