# Code written by Jacob Hansen

# Import python libraries
import time
import numpy as np
import matplotlib.pyplot as plt
cimport numpy as np

# create the body of the code as a function
def Diff_Evo_Cython():

# Define bounds and critical variables as c data types
    cdef double low, high, CR, F, cost2, cost3, s, t, r, z
    cdef int dim, count, i, l, kk, k,Q
    cdef np.ndarray NP, NPD, a, b, c, N, one, x, y, idx, result
# save start time
    t = time.time()
# define bounds and variables
    low = -7
    high = 7
    dim = 4
    CR = 0.9  # Crossover probability
    F = 0.7   # Differential weight
    a = np.zeros(dim)
    b = np.zeros(dim)
    c = np.zeros(dim)
    s = 1
    count = 0
    cost2 = 1
    cost3 = 1
# Population size and initialization
    NP = np.linspace(low, high, dim*4)
    one = np.ones(len(NP))
    NP = NP.reshape(1, -1)
    for z in range(dim-1):
        NP = np.vstack([NP, NP[0, :]])
    N = np.arange(dim)
# Start while loop
    while cost2 > 0.0001 and cost3 > 0.001:
        count += 1
% select agents
        x = np.random.permutation(NP.shape[1])[:5]
% perform a comparison for each agent
        for k in range(len(x)):
% remove the agent and create a b c arrays
            NPD = NP.copy()
            kk=int(x[k])
            NPD = np.delete(NPD, kk, axis=1)
            idx = np.random.permutation(NPD.shape[1])[:dim*3]
            for l in range(dim):
                r = int((l)*3)
                a[l] = NPD[l, idx[int(r)]]
                b[l] = NPD[l, idx[int(r+1)]]
                c[l] = NPD[l, idx[int(r+2)]]
            y = np.zeros(dim)
            for i in range(dim):
                r = np.random.rand()
# determine the value of the canidate
                if r < CR or i == N[i]:
                    y[i] = a[i] + F * (b[i] - c[i])
                else:
                    y[i] = NP[i, x[k]]
# compare cost functions
            if np.abs((y[0]-1)**2 + (y[1]-6)**2 + (y[2])**2 + (y[3]+5)**2) < \
                np.abs((NP[0, x[k]]-1)**2 + (NP[1, x[k]]-6)**2 + (NP[2, x[k]])**2 + (NP[3, x[k]]+5)**2):
                NP[:, x[k]] = y
# calculate ending variables
        cost2 = np.mean(np.abs((NP[0, :]-1)**2 + (NP[1, :]-6)**2 + (NP[2, :])**2 + (NP[3, :]+5)**2))
        cost3 = np.mean(np.std(NP, axis=1))
# reporting
    result = np.mean(NP, axis=1)
    print("Result:", result)
    elapsed = time.time() - t
    print(elapsed)
    print(count)