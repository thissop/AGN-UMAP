import torch
from accelerate import Accelerator
import pandas as pd

# hardware optimization
accelerator = Accelerator(mixed_precision='fp16')

# get code, instrument, and pretrained spectrum model from the hub
github = "pmelchior/spender"
sdss, model = torch.hub.load(github, 'sdss_II',  map_location=accelerator.device)
model = model.to('cpu')
# get some SDSS spectra from the ids, store locally in data_path
from spender.data.sdss import SDSS
data_path = "./DATA"

key_df = pd.read_csv('/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/feb2024/wk4/key.csv')

ids = ((412, 52254, 308), (412, 52250, 129)) # plate, mjd, fiberid
spec, w, z, norm, zerr = SDSS.make_batch(data_path, ids)

# run spender end-to-end
with torch.no_grad():
  spec_reco = model(spec, instrument=sdss, z=z)

# only encode into latents
with torch.no_grad():
  s = model.encode(spec)

print(s)