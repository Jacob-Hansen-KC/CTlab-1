# Keywords to enable faster computing
# cython: boundscheck=False, wraparound=False, cdivision=True
#Import modules
import numpy as np
cimport numpy as np
from Heat_Transfer_Cython_3 import Heat_Transfer_Cython as heat_transfer
#Define program as a function to allow memory allocation 
def Phase_Three_Cython(np.ndarray[np.float64_t, ndim=1] value,np.ndarray[np.int32_t, ndim=1] X2,np.ndarray[np.int32_t, ndim=1] Y2):
# predefine c data types
    cdef double low = 100.0, high = 750.0, CR = 0.9, F = 0.6
    cdef double cost2 = 1.0, cost3 = 1.0, r, new, old
    cdef int dim = 4, count = 0, i, l, k, pop_size = dim * 6
    cdef np.ndarray[np.float64_t, ndim=1] a = np.zeros(dim), b = np.zeros(dim), c = np.zeros(dim)
    cdef np.ndarray[np.float64_t, ndim=1] y = np.zeros(dim)
    cdef np.ndarray[np.float64_t, ndim=2] NP, NPD, NPstore
    cdef np.ndarray[int, ndim=1] idx, x
    cdef np.ndarray[np.float64_t, ndim=2] T1
    cdef np.ndarray[np.float64_t, ndim=1] K1
    cdef np.ndarray[np.float64_t, ndim=1] N_init
    cdef np.ndarray[np.float64_t, ndim=1] result, result2
# Create the NP and NPstore arrays
    N_init = np.linspace(low, high, pop_size)
    NP = np.tile(N_init, (dim, 1))
    NPstore = NP * 1000.0
# begin the while loop with end conditions based on cost function 
#and std deviation of the solution set
    while cost2 > 0.01 or cost3 > 0.05:
        count += 1
# select 5 random agents X
        x = np.random.permutation(pop_size)[:5]
# For each agent select an a b and c and create a new value of y using them
        for k in range(5):
            NPD = NP.copy()
            NPD = np.delete(NPD, x[k], axis=1)
            idx = np.random.permutation(NPD.shape[1])[:dim*3]
            for l in range(dim):
                a[l] = NPD[l, idx[l*3]]
                b[l] = NPD[l, idx[l*3+1]]
                c[l] = NPD[l, idx[l*3+2]]
            for i in range(dim):
                r = np.random.rand()
                if r < CR:
                    y[i] = a[i] + F * (b[i] - c[i])
                    y = np.where(y < 0.0, np.mean(NP[i]), y)
                else:
                    y[i] = NP[i, x[k]] 
# Calculate the temperatures in the desired positions based on the new boundary temperatures
            T1 = heat_transfer(y)
            K1 = np.array([T1[X2[0],Y2[0]], T1[X2[1],Y2[1]], T1[X2[2],Y2[2]], T1[X2[3],Y2[3]]], dtype=np.float64)
# Determine the value of the new and old cost function
            new = np.sum((K1 - value) ** 2)
            old = np.sum((NPstore[:, x[k]] - value) ** 2)
# If the new value is better replace the old value
            if new < old:
                NP[:, x[k]] = y
                NPstore[:, x[k]] = K1
# determine the cost functions that end the while loop
        cost2 = np.mean(np.sum((NPstore - value[:, None]) ** 2, axis=0))
        cost3 = np.mean(np.std(NP, axis=1))
        # Comment out print for performance
# Print information to see how the optimization is progressing
        print(cost2,cost3,count,np.mean(NP[0]),np.mean(NP[1]),np.mean(NP[2]),np.mean(NP[3]))
        if cost3<0.005:
            break

# Report final values as outputs
    result = np.mean(NP, axis=1)
    result2 = np.mean(NPstore, axis=1)
    # Comment out prints for performance
    # print("Final Boundary Conditions:", result)
    # print("Result:", result2)
    # print(count)
    return result, result2, count