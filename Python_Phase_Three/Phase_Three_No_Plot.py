import time
from Heat_Transfer_Numba_2 import Heat_Transfer_Func as heat_transfer  # Assuming heat_transfer is a module you have created
t = time.time()
import numpy as np

# --- Differential Evolution Setup ---
low = 280
high = 310
dim = 4
NP = np.linspace(low, high, dim*4)
one = np.ones(len(NP))
NP = NP.reshape(1, -1)
for z in range(dim-1):
    NP = np.vstack([NP, NP[0, :]])
NPstore = NP * 1000
N = np.arange(dim)
CR = 0.9
F = 0.8
a = np.zeros(dim)
b = np.zeros(dim)
c = np.zeros(dim)
s = 10
# x1 = np.array([10, 35, 16, 35],dtype=int)
# y1 = np.array([10, 40, 45, 16],dtype=int)
# targets = np.array([150, 225, 225, 300],dtype=int)
x1 = np.array([4, 17, 15, 7],dtype=int)
y1 = np.array([4, 14, 8, 15],dtype=int)
targets = np.array([277, 283, 283, 280],dtype=int)
count = 0
cost2 = 1
cost3 = 1
costlist = []
# --- Differential Evolution Loop ---
while cost2 > 0.01 or cost3 > 0.05:
    count += 1
    x = np.random.permutation(NP.shape[1])[:5]
    for k in range(len(x)):
        NP2 = NP.copy()
        NP2 = np.delete(NP2, x[k], axis=1)
        idx = np.random.permutation(NP2.shape[1])[:dim*3]
        for l in range(dim):
            r = l*3
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
        y = np.maximum(y, 0)
        # Run the heat transfer code for the new value
        T1 = heat_transfer(y)
        K1 = [T1[x1[0], y1[0]], T1[x1[1], y1[1]], T1[x1[2], y1[2]], T1[x1[3], y1[3]]]
        # Define target values
        # Calculate 'new'
        new = np.sum((np.array(K1) - targets) ** 2)
        # Calculate 'old'
        old = np.sum((NPstore[:, x[k]] - targets) ** 2)
        if new < old:
            NP[:, x[k]] = y
            NPstore[:, x[k]] = K1
    # Calculate 'cost2'
    cost2 = np.mean(np.sum((NPstore - targets[:, None]) ** 2, axis=0))
    cost3 = np.mean(np.std(NP, axis=1))
    print(cost2)

result = np.mean(NP, axis=1)
result2= np.mean(NPstore, axis=1)
print("Final Boundary Conditions:", result)
print("Result:", result2)
elapsed = time.time() - t
print(elapsed)
print(count)
print(elapsed/count, "seconds per iteration")