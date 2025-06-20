# cython: boundscheck=False, wraparound=False, cdivision=True
import numpy as np
cimport numpy as np

def Diff_Evo_Cython():
    cdef double low = -7.0, high = 7.0, CR = 0.9, F = 0.7
    cdef double cost2 = 1.0, cost3 = 1.0, r
    cdef int dim = 4, count = 0, i, l, kk, k, pop_size
    cdef np.ndarray[np.float64_t, ndim=1] a = np.zeros(dim), b = np.zeros(dim), c = np.zeros(dim)
    cdef np.ndarray[np.float64_t, ndim=1] y = np.zeros(dim)
    cdef np.ndarray[np.float64_t, ndim=2] NP, NPD
    cdef np.ndarray[int, ndim=1] idx, x
    cdef np.ndarray[np.float64_t, ndim=1] N = np.arange(dim, dtype=np.float64)
    cdef np.ndarray[np.float64_t, ndim=1] result

    # Population size and initialization
    pop_size = dim * 4
    N_init = np.linspace(low, high, pop_size)
    NP = np.tile(N_init, (dim, 1))

    while cost2 > 0.0001 and cost3 > 0.001:
        count += 1
        x = np.random.permutation(pop_size)[:5]
        for k in range(len(x)):
            NPD = NP.copy()
            kk = int(x[k])
            NPD = np.delete(NPD, kk, axis=1)
            idx = np.random.permutation(NPD.shape[1])[:dim*3]
            for l in range(dim):
                a[l] = NPD[l, idx[l*3]]
                b[l] = NPD[l, idx[l*3+1]]
                c[l] = NPD[l, idx[l*3+2]]
            for i in range(dim):
                r = np.random.rand()
                if r < CR or i == int(N[i]):
                    y[i] = a[i] + F * (b[i] - c[i])
                else:
                    y[i] = NP[i, x[k]]
            # Cost function
            if abs((y[0]-1)**2 + (y[1]-6)**2 + (y[2])**2 + (y[3]+5)**2) < \
               abs((NP[0, x[k]]-1)**2 + (NP[1, x[k]]-6)**2 + (NP[2, x[k]])**2 + (NP[3, x[k]]+5)**2):
                NP[:, x[k]] = y
        cost2 = np.mean(np.abs((NP[0, :]-1)**2 + (NP[1, :]-6)**2 + (NP[2, :])**2 + (NP[3, :]+5)**2))
        cost3 = np.mean(np.std(NP, axis=1))
    result = np.mean(NP, axis=1)
    return count
