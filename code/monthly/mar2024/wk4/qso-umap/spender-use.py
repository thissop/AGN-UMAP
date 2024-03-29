import torch
import pandas as pd 
from spender.data.sdss import SDSS


github = "pmelchior/spender"
sdss, model = torch.hub.load(github, 'sdss_II')

data_path = "/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/data/sdss-qso-catalogue/spectra"

df = pd.read_csv('/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/data/sdss-qso-catalogue/QSO_catalogue.csv')

plates, mjds, fiberids = df['plate'], df['mjd'], df['fiberid']

ids = ((plates[i], mjds[i], fiberids[i]) for i in range(0,5000))

spec, w, z, norm, zerr = SDSS.make_batch(data_path, ids)

# only encode into latents
with torch.no_grad():
    s = model.encode(spec)