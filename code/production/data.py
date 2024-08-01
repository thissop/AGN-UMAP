def download_data(key_df:str='/Users/tkiker/Documents/GitHub/AGN-UMAP/code/monthly/aug2024/wk1/quasar_key.csv', save_dir:str='/Users/tkiker/Documents/GitHub/AGN-UMAP/data/sdss_spectra'):
    from tqdm import tqdm 
    import requests
    import pandas as pd 
    import os 

    key_df = pd.read_csv(key_df)
    plates = key_df['PLATE'].values
    mjds = key_df['MJD'].values 
    fiber_IDs = key_df['FIBERID'].values 

    for plate, mjd, fiber_ID in tqdm(zip(plates, mjds, fiber_IDs)): 
        fiber_ID = str(fiber_ID)
        if len(fiber_ID) < 4: 
            fiber_ID = (4-len(fiber_ID))*'0' + fiber_ID
        
        plate = str(plate)
        if len(plate) < 4: 
            plate = (4-len(plate))*'0' + plate

        mjd = str(mjd)
        
        # https://data.sdss.org/sas/dr17/eboss/spectro/redux/v5_13_2/spectra/full/3586/spec-3586-55181-0890.fits
        file_url = f'https://data.sdss.org/sas/dr17/eboss/spectro/redux/v5_13_2/spectra/full/{plate}/spec-{plate}-{mjd}-{fiber_ID}.fits'
        
        try:
            response = requests.get(file_url)
            response.raise_for_status()
            
            file_path = os.path.join(save_dir, f'spec-{plate}-{mjd}-{fiber_ID}.fits')

            with open(file_path, 'wb') as file:
                file.write(response.content)
            
            #print(f"Downloaded file and saved to {file_path}")

        except requests.exceptions.HTTPError as http_err:
            print(f"HTTP error occurred: {http_err}")
        except Exception as err:
            print(f"An error occurred: {err}")

download_data()