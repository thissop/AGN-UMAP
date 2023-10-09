import os 
import pandas as pd 
import matplotlib.pyplot as plt 
import numpy as np
import re
from sklearn.preprocessing import MinMaxScaler

# check in with colin tn! 

# check in with uraz next week
def prep_data(): 
    d = 'data/Kuraszkiewicz2004AGNSpectra'
    for f in os.listdir(d):
        #os.rename(os.path.join(d,f), os.path.join(d, f.replace('.dat', '.txt')))
        fp = os.path.join(d,f)
        if '.dat' not in fp:  
            #os.remove(fp)
            continue 

        else: 
            os.remove(fp)
            continue 
            lines = ['Wavelength (Ang),Flux']#,Error']
            with open(fp, 'r') as fi: 
                for line in fi: 
                    line = ','.join(re.sub(' +',',', line).split(',')[1:3])
                    lines.append(line)

            with open(fp.replace('.dat', '.csv'), 'w') as fi: 
                for line in lines: 
                    fi.write(line+'\n') 

                
            
            '''
            df = pd.read_csv(fp)
            df['Flux'] = MinMaxScaler().fit_transform(np.array(df['Flux']).reshape(-1,1))
            df.to_csv(fp, index=False)

            fig, ax = plt.subplots()

            ax.plot(df['Wavelength (Ang)'], df['Flux'])

            ax.set(xlabel='Wavelength (ang)', ylabel='Normalized Flux')

            plt.tight_layout()
            save_path = os.path.join('personal/thaddaeus/monthly/june2023/wk4/plots', f.replace('.csv', '.png'))
            plt.savefig(save_path, dpi=200)

            plt.clf()
            plt.close()
            '''

def prep_table_one(): 
    from astropy.table import Table
    import pandas as pd

    filename = 'personal/thaddaeus/monthly/june2023/wk4/table-1.txt'
    output_file = "output.txt"  # Replace with the path to the output file

    import re

    output_file = "output.txt"  # Replace with the path to the output file

    '''
    with open(filename, "r") as file:
        lines = file.readlines()

    with open(output_file, "w") as file:
        for line in lines:
            if len(line) > 17:
                modified_line = line[:17] + line[17:].replace(" ", ",")
                print(modified_line)
                file.write(modified_line)
        else:
            file.write(line)
    '''


    print(pd.read_csv(output_file))

prep_table_one()