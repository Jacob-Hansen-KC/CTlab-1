# cython: boundscheck=False, wraparound=False, cdivision=True
import time
import numpy as np
import matplotlib.pyplot as plt
cimport numpy as np

# Define bounds and critical variables
def Diff_Evo_Cython():
    cdef double low, high, CR, F, cost2, cost3, s, t, r, z
    cdef int dim, count, i, l, kk, k,Q
    cdef np.ndarray[np.float64_t, ndim=1] a, b, c, N, one, y, result
    cdef np.ndarray[np.float64_t, ndim=2] NP, NPD,
    cdef np.ndarray[int, ndim=1] idx, x
    t = time.time()
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

    N = np.linspace(low, high, dim*4)
    NP = np.tile(N, (4, 1))
    N = np.arange(dim, dtype=np.float64)
    while cost2 > 0.0001 and cost3 > 0.001:
        count += 1
        x = np.random.permutation(NP.shape[1])[:5]
        for k in range(len(x)):
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
    #print("Result:", result)
    elapsed = time.time() - t
    #print(elapsed)
    #print(elapsed/count)
    #print(count)
    return count
