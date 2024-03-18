import numpy as np

import matplotlib.pyplot as plt

x = np.linspace(0.1, 10, num=128)

print(len(np.where(x<5)[0]))
print(len(np.where(x>=5)[0]))

plt.xlim((0.1,10))
plt.xscale('log')

plt.xticks(x)

plt.show()