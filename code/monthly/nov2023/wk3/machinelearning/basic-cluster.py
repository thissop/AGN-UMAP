import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import umap
import os

data_directory = '/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/nov2023/wk1/qsofitmore/output/processed_data/'
data = []
types = []

for filename in os.listdir(data_directory):
    csv_path = os.path.join(data_directory, filename)
    df = pd.read_csv(csv_path)
    wavelength = np.array(df['x'])
    flux = np.array(df['continuum'])+np.array(df['model'])
    data.append(flux)

data = np.array(data)

reducer = umap.UMAP(n_components=2)
reduced_data = reducer.fit_transform(data)

# Plot the Reduced Data 

plt.scatter(reduced_data[:, 0], reduced_data[:, 1], s=5)
plt.title("UMAP Visualization of Encoded Data")
plt.xlabel("UMAP Dimension 1")
plt.ylabel("UMAP Dimension 2")
plt.savefig('/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/nov2023/wk3/machinelearning/plots/umap.png', dpi=250)