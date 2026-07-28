import numpy as np 
import matplotlib.pyplot as plt 
import smplotlib 

n_simulations = 1000

n_attackers = int(input('Enter # of Attackers: '))
n_defenders = int(input('Enter # of Defenders: '))

outcomes = []

for N in range(n_simulations):

    n_attackers_i = n_attackers
    n_defenders_i = n_defenders

    while n_attackers>0 and n_defenders>0: 
        attacker_rolls = np.sort([np.random.randint(1, 6) for i in range(min(n_attackers_i, 3))])
        defender_rolls = np.sort([np.random.randint(1, 6) for i in range(min(n_defenders_i, 2))])

        while len(defender_rolls>0) and len(attacker_rolls>0): 
            max_defender = defender_rolls[-1]
            max_attacker = attacker_rolls[-1]

            if max_attacker>max_defender: 
                defender_rolls = p
