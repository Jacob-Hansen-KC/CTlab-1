import time
from Heat_Transfer_Func import Heat_Transfer_Func as heat_transfer  # Assuming heat_transfer is a module you have created
t = time.time()
import numpy as np

# --- Differential Evolution Setup ---
low = 260
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
        # Run the heat transfer code for the new value
        T1 = heat_transfer(y)
        K1 = [T1[5,5], T1[18,15], T1[16,9], T1[8,16]]
        # Calculate value of the cost function for each set
        new = (K1[0]-277)**2 + (K1[1]-283)**2 + (K1[2]-280)**2 + (K1[3]-280)**2
        old = (NPstore[0, x[k]]-277)**2 + (NPstore[1, x[k]]-283)**2 + (NPstore[2, x[k]]-280)**2 + (NPstore[3, x[k]]-280)**2
        if new < old:
            NP[:, x[k]] = y
            NPstore[:, x[k]] = K1
    cost2 = np.mean((NPstore[0, :]-277)**2 + (NPstore[1, :]-283)**2 + (NPstore[2, :]-280)**2 + (NPstore[3, :]-280)**2)
    cost3 = np.mean(np.std(NP, axis=1))
    print(count)

result = np.mean(NP, axis=1)
result2= np.mean(NPstore, axis=1)
print("Final Boundary Conditions:", result)
print("Result:", result2)
elapsed = time.time() - t
print(elapsed)