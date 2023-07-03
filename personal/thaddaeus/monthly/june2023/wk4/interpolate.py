import os
import numpy as np
import pandas as pd
from scipy.interpolate import interp1d
from sklearn.preprocessing import MinMaxScaler

data_directory = 'data/cluster-one'
output_directory = 'data/ProcessedSpectra'

X = []

if len(os.listdir(output_directory)) == 0: 
    spectra = []
    for filename in os.listdir(data_directory):
        filepath = os.path.join(data_directory, filename)
        df = pd.read_csv(filepath)
        spectra.append((filename, df))

    min_wavelength = min(df['Wavelength (Ang)'].min() for _, df in spectra)
    max_wavelength = max(df['Wavelength (Ang)'].max() for _, df in spectra)

    num = np.mean([len(i['Flux']) for _, i in spectra]) # 2601 
    num = int(num - num%500) # 2500

    # Resample spectra to a uniform wavelength grid
    wavelength_grid = np.linspace(min_wavelength, max_wavelength, num=num)
    resampled_spectra = []

    for filename, df in spectra:
        min_spectrum_wavelength = df['Wavelength (Ang)'].min()
        max_spectrum_wavelength = df['Wavelength (Ang)'].max()

        # Perform interpolation within the spectrum's range
        interp_func = interp1d(df['Wavelength (Ang)'], df['Flux'], bounds_error=False, fill_value=0)
        resampled_flux = interp_func(wavelength_grid)
        
        resampled_spectra.append((filename, resampled_flux))

    scaler = MinMaxScaler()
    normalized_spectra = [(filename, scaler.fit_transform([spectrum])[0]) for filename, spectrum in resampled_spectra]

    if not os.path.exists(output_directory):
        os.makedirs(output_directory)

    for filename, spectrum in normalized_spectra:
        output_filename = os.path.join(output_directory, filename)
        output_data = pd.DataFrame({'Wavelength (Ang)': wavelength_grid, 'Flux': spectrum})
        output_data.to_csv(output_filename, index=False)
        X.append(spectrum)

else: 
    for filename in os.listdir(output_directory):
        df = pd.read_csv(os.path.join(output_directory, filename))
        X.append(df['Flux'])
    
print(np.max(X))