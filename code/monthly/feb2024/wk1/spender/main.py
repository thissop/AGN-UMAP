import torch.hub
github = "pmelchior/spender"

# get the spender code and show list of pretrained models
#torch.hub.list(github)

# print out details for SDSS model from paper II
#print(torch.hub.help(github, 'sdss_II'))

# load instrument and spectrum model from the hub
#sdss, model = torch.hub.load(github, 'sdss_II')

# if your machine does not have GPUs, specify the device
from accelerate import Accelerator
accelerator = Accelerator(mixed_precision='fp16')
sdss, model = torch.hub.load(github, 'sdss_II', map_location=accelerator.device)

import torch
from accelerate import Accelerator

# hardware optimization
accelerator = Accelerator(mixed_precision='fp16')

# get code, instrument, and pretrained spectrum model from the hub
github = "pmelchior/spender"
sdss, model = torch.hub.load(github, 'sdss_II',  map_location=accelerator.device)

# get some SDSS spectra from the ids, store locally in data_path
from spender.data.sdss import SDSS
data_path = "/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/feb2024/wk1/spender/data"
ids = ((412, 52254, 308), (412, 52250, 129))
spec, w, z, norm, zerr = SDSS.make_batch(data_path, ids)

# only encode into latents

latent_space = []

with torch.no_grad():
  s = model.encode(spec)
  latent_space.append(s)