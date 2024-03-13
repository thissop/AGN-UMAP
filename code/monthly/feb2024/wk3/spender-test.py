import matplotlib.pyplot as plt 
import pandas as pd 
import numpy as np

plt.style.use('/Users/yaroslav/Documents/2. work/Research/GitHub/SummerEconProject/pre-project/nus-evaluation/code/style.mplstyle')

df1 = pd.read_csv('/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/feb2024/wk3/spender.desi-edr.full-bgs-objects-logP.txt')

fig, ax = plt.subplots()

#ax.scatter(df['object_number'], df['chi_galaxy'])
percentile_cut = 0.05

count = percentile_cut*len(df1.index)

ax.scatter(range(0,1000), df1['chi_galaxy'][0:1000])
ax.set(yscale='log', xlabel='Rank', ylabel='log(chi_galaxy)')

#ax.scatter(range(0, 1000), df1['P_galaxy_rank(%)'][0:1000])
#ax.set(xlabel='Rank', ylabel='P_galaxy_rank(%)')

plt.savefig('code/monthly/feb2024/wk3/desi.png')
plt.close()

df2 = pd.read_csv('/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/feb2024/wk3/spender.sdss.paperII.logP.txt')

fig, axs = plt.subplots(1, 2, figsize=(10,4))

df2 = df2.sort_values(by='-logP', ascending=False)

#ax.scatter(df['object_number'], df['chi_galaxy'])
percentile_cut = 0.05
y_cut = -np.log10(percentile_cut)

count = sum(df2['-logP']>y_cut)

axs[0].set(xscale='log')
axs[0].scatter(range(0, len(df2.index)), df2['-logP'])
axs[0].axvline(x=count, color='red', label=r'$P_G<$'+f'{percentile_cut*100}%\nn={count} ({round(100*count/len(df2.index),1)}% of Total)')
axs[0].axhline(y=y_cut, color='red')
axs[0].legend()

axs[1].scatter(range(0, len(df2.index)), df2['-logP'])
axs[1].axvline(x=count, color='red')
axs[1].axhline(y=y_cut, color='red')
#print(sum(df['chi_galaxy']>2))
fig.supxlabel('Index')
fig.supylabel(r'$-$'+'log'+'$(p)$')

plt.savefig('code/monthly/feb2024/wk3/sdss_II.png')

plt.show()



