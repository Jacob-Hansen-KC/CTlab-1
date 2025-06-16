# cython: boundscheck=False, wraparound=False, cdivision=True
import time
from Heat_Transfer_Cython_F import Heat_Transfer_Cython as heat_transfer
import numpy as np
cimport numpy as np
# --- Differential Evolution Setup --
# Define bounds and critical variables
def Phase_Three_Cython(val):
    cdef double low, high, CR, F, cost2, cost3, t, r, new, old,
    cdef int dim, count, i, l, k,
    cdef np.ndarray[np.float64_t, ndim=1] a, b, c, N, y, result, value,K1,
    cdef np.ndarray[np.float64_t, ndim=2] NP, NPD, T2, T1, NPstore,
    cdef np.ndarray[int, ndim=1] idx, x
    t = time.time()
    value=val
    low = 260
    high = 310
    dim = 4
    N = np.linspace(low, high, dim*4)
    NP = np.tile(N, (4, 1))
    N = np.arange(dim, dtype=np.float64)
    NPstore = NP * 1000
    CR = 0.9
    F = 0.7
    a = np.zeros(dim)
    b = np.zeros(dim)
    c = np.zeros(dim)
    count = 0
    cost2 = 1
    cost3 = 1

# --- Differential Evolution Loop ---
    while cost2 > 0.01 or cost3 > 0.05:
        count += 1
        x = np.random.permutation(NP.shape[1])[:5]
        for k in range(len(x)):
            NPD = NP.copy()
            NPD = np.delete(NPD, x[k], axis=1)
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
        #remove too low value of y
            y = np.maximum(y, 0)
        # Run the heat transfer code for the new value
########################################################################################
            T2 = heat_transfer(y)
########################################################################################
            T1 = T2
            K1 = np.array([T1[4,4], T1[17,14], T1[15,8], T1[7,15]])
        # Calculate value of the cost function for each set
            new = (K1[0]-value[0])**2 + (K1[1]-value[1])**2 + (K1[2]-value[2])**2 + (K1[3]-value[3])**2
            old = (NPstore[0, x[k]]-value[0])**2 + (NPstore[1, x[k]]-value[1])**2 + (NPstore[2, x[k]]-value[2])**2 + (NPstore[3, x[k]]-value[3])**2
            if new < old:
                NP[:, x[k]] = y
                NPstore[:, x[k]] = K1
        cost2 = np.mean((NPstore[0, :]-value[0])**2 + (NPstore[1, :]-value[1])**2 + (NPstore[2, :]-value[2])**2 + (NPstore[3, :]-value[3])**2)
        cost3 = np.mean(np.std(NP, axis=1))
        print(cost2)

    result = np.mean(NP, axis=1)
    result2= np.mean(NPstore, axis=1)
    print("Final Boundary Conditions:", result)
    print("Result:", result2)
    elapsed = time.time() - t
    print(elapsed)
    print(count)