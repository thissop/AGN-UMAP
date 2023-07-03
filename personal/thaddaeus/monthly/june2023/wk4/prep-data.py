import os 
import pandas as pd 
import matplotlib.pyplot as plt 
import numpy as np
import re
from sklearn.preprocessing import MinMaxScaler

# check in with colin tn! 

# check in with uraz next week

d = 'data/Kuraszkiewicz2004AGNSpectra'
for f in os.listdir(d):
    #os.rename(os.path.join(d,f), os.path.join(d, f.replace('.dat', '.txt')))
    
    fp = os.path.join(d,f)
    '''
    lines = ['Wavelength (Ang),Flux,Error']
    with open(fp, 'r') as fi: 
        for line in fi: 
            line = ','.join(re.sub(' +',',', line).split(',')[1:4])
            lines.append(line)

    with open(fp.replace('.dat', '.csv'), 'w') as fi: 
        for line in lines: 
            fi.write(line+'\n')
    
    continue 
    '''
    if '.dat' in fp: 
        os.remove(fp)
    else: 
        
        df = pd.read_csv(fp)
        df['Flux'] = MinMaxScaler().fit_transform(np.array(df['Flux']).reshape(-1,1))
        df.to_csv(fp)

        fig, ax = plt.subplots()

        ax.plot(df['Wavelength (Ang)'], df['Flux'])

        ax.set(xlabel='Wavelength (ang)', ylabel='Normalized Flux')

        plt.tight_layout()
        save_path = os.path.join('personal/thaddaeus/monthly/june2023/wk4/plots', f.replace('.csv', '.png'))
        plt.savefig(save_path, dpi=200)

        plt.clf()
        plt.close()