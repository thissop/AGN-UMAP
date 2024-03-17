import torch.hub
github = "pmelchior/spender"

# get the spender code and show list of pretrained models
torch.hub.list(github)

# print out details for SDSS model from paper II
print(torch.hub.help(github, 'sdss_II'))

# load instrument and spectrum model from the hub
sdss, model = torch.hub.load(github, 'sdss_II', map_location=torch.device('cpu'))

state_dict = model.state_dict()
keys, arrays = list(state_dict.keys()), list(state_dict.values())
shapes = [state_dict[keys[i]].size() for i in range(len(keys))]

for key, shape in zip(keys, shapes):
    print(f'{key:<30} ||    {shape}')

# get some SDSS spectra from the ids, store locally in data_path
from spender.data.sdss import SDSS
data_path = "./DATA"
ids = ((412, 52254, 308), (412, 52250, 129))
spec, w, z, norm, zerr = SDSS.make_batch(data_path, ids)

with torch.no_grad():
  s = model.encode(spec)

print(spec.size())

from torchsummary import summary
summary(model, input_size=(2,1,3921))

# for (1,2,3921) got [2, 1, 1, 2, 3921] 
# for (2,3921) got [2, 1, 2, 3921] 
# for (2,1,3921) got [2, 1, 2, 1, 3921]