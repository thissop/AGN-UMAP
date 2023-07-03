import os
import numpy as np
import pandas as pd
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score
import matplotlib.pyplot as plt
from scipy.spatial.distance import cdist
from sklearn.preprocessing import MinMaxScaler


data_directory = 'data/Kuraszkiewicz2004AGNSpectra'
spectra = []
sources = []
for filename in os.listdir(data_directory):
    filepath = os.path.join(data_directory, filename)
    df = pd.read_csv(filepath)
    spectra.append(df)
    sources.append(filename.split('.')[0])

wavelength_ranges = []
for df in spectra:
    min_wavelength = df['Wavelength (Ang)'].min()
    max_wavelength = df['Wavelength (Ang)'].max()
    wavelength_ranges.append([min_wavelength, max_wavelength])

def test_clustering(): 

    # Perform K-means clustering for different values of n_clusters
    n_clusters_range = range(1, 11)  # Adjust the range as desired
    wcss = []
    silhouette_scores = []
    for n_clusters in n_clusters_range:
        kmeans = KMeans(n_clusters=n_clusters, random_state=42)
        kmeans.fit(wavelength_ranges) # The elbow method plots the within-cluster sum of squares (WCSS) against the number of clusters and looks for the "elbow" point where the rate of decrease in WCSS slows down significantly.
        wcss.append(sum(np.min(cdist(wavelength_ranges, kmeans.cluster_centers_, 'euclidean'), axis=1)) / len(wavelength_ranges))
        labels = kmeans.labels_
        unique_labels = np.unique(labels)
        if len(unique_labels) < 2:
            silhouette_scores.append(0)  # Assign a score of 0 if there's only one unique label
        else:
            silhouette_scores.append(silhouette_score(wavelength_ranges, labels)) # The optimal number of clusters can be chosen as the one that maximizes the silhouette score.

    # Plot the elbow curve and silhouette scores

    fig, axs = plt.subplots(2,1)

    ax = axs[0]
    ax.plot(n_clusters_range, wcss, marker='o')
    ax.set(xlabel='Number of Clusters', ylabel='WCSS', title='Elbow Method')
    ax = axs[1]
    ax.plot(n_clusters_range, silhouette_scores, marker='o')
    ax.set(xlabel='Number of Clusters', ylabel='Silhouette Score', title='Silhouette Score Method')

    plt.tight_layout()
    plt.savefig('personal/thaddaeus/monthly/june2023/wk4/analysis-plots/cluster-curves.png', dpi=250)

def execute_clustering(n_clusters:int=2): 
    # Perform clustering based on wavelength range
    kmeans = KMeans(n_clusters=n_clusters, random_state=42)
    cluster_labels = kmeans.fit_predict(wavelength_ranges)

    # Group spectra based on cluster labels
    spectra_groups = [[] for _ in range(n_clusters)]
    sources_groups = [[] for _ in range(n_clusters)]
    for i, label in enumerate(cluster_labels):
        spectra_groups[label].append(spectra[i])
        sources_groups[label].append(sources[i])

    for i, group in enumerate(spectra_groups):
        print(f"Group {i+1}:")
        mins = []
        maxs = []
        for j, df in enumerate(group):
            min_wavelength = df['Wavelength (Ang)'].min()
            max_wavelength = df['Wavelength (Ang)'].max()

            if i == 0:
                new_df = pd.DataFrame()
                new_df['Wavelength (Ang)'] = df['Wavelength (Ang)']
                new_df['Flux'] = df['Flux']/np.max(df['Flux'])#MinMaxScaler().fit_transform(X=np.array(df['Flux']).reshape(-1,1))
                print(max(df['Flux']))
                df.to_csv(f'data/cluster-one/{sources_groups[0][j]}.csv', index=False)

            #print(f"  - Range: {min_wavelength} - {max_wavelength}")
            mins.append(min_wavelength)
            maxs.append(max_wavelength)
        
        print(min(mins), np.std(mins))
        print(max(maxs), np.std(maxs))

execute_clustering()