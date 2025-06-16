import time
t = time.time()
import numpy as np
import matplotlib.pyplot as plt

# Define bounds and critical variables
low = -7
high = 7
dim = 4

# Population size and initialization
NP = np.linspace(low, high, dim*4)
one = np.ones(len(NP))
NP = NP.reshape(1, -1)
for z in range(dim-1):
    NP = np.vstack([NP, NP[0, :]])
N = np.arange(dim)
CR = 0.9  # Crossover probability
F = 0.7   # Differential weight

a = np.zeros(dim)
b = np.zeros(dim)
c = np.zeros(dim)
s = 1
count = 0
cost2 = 1
cost3 = 1

while cost2 > 0.0001 or cost3 > 0.001:
    count += 1
    x = np.random.permutation(NP.shape[1])[:5]
    for k in range(len(x)):
        NP2 = NP.copy()
        NP2 = np.delete(NP2, x[k], axis=1)
        idx = np.random.permutation(NP2.shape[1])[:dim*3]
        for l in range(dim):
            r = (l)*3
            a[l] = NP2[l, idx[r]]
            b[l] = NP2[l, idx[r+1]]
            c[l] = NP2[l, idx[r+2]]
        y = np.zeros(dim)
        for i in range(dim):
            r = np.random.rand()
            if r < CR or i == N[i]:
                y[i] = a[i] + F * (b[i] - c[i])
            else:
                y[i] = NP[i, x[k]]
        # Cost function
        if np.abs((y[0]-1)**2 + (y[1]-6)**2 + (y[2])**2 + (y[3]+5)**2) < \
           np.abs((NP[0, x[k]]-1)**2 + (NP[1, x[k]]-6)**2 + (NP[2, x[k]])**2 + (NP[3, x[k]]+5)**2):
            NP[:, x[k]] = y
    cost2 = np.mean(np.abs((NP[0, :]-1)**2 + (NP[1, :]-6)**2 + (NP[2, :])**2 + (NP[3, :]+5)**2))
    cost3 = np.mean(np.std(NP, axis=1))

result = np.mean(NP, axis=1)
print("Result:", result)
elapsed = time.time() - t
print(elapsed)
print(count)