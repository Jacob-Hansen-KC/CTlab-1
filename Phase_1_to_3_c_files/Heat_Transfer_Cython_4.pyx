# Keywords to enable faster computing
# cython: boundscheck=False, wraparound=False, cdivision=True, nonecheck=False, initializedcheck=False

# import libraries
import numpy as np
cimport numpy as np
import time
# from libc.math cimport fabs #alt loop condition

# begin the function with the boundary conditions being the input
def Heat_Transfer_Cython(np.ndarray[np.float64_t, ndim=1] bdry1):
# define all variables in c data types
    cdef double alpha = 0.000097  # m^2/s
    cdef int s = 600
    cdef double dx2 = 1/(0.01 * 0.01), dy2 = 1/(0.01 * 0.01), dt = 0.25, end, start, timet
    cdef int k = 0, i, j, l
    cdef double value = 1.0, diff, sum_diff
    cdef np.ndarray[np.float64_t, ndim=2] T2 = np.ones((s+2, s+2), dtype=np.float64) * 273.15
    cdef np.ndarray[np.float64_t, ndim=2] T1 = np.zeros((s+2, s+2), dtype=np.float64)
    cdef np.ndarray[np.float64_t, ndim=2] S = np.zeros((s+2, s+2), dtype=np.float64)
    #S[24, 24] = 100.0

# boundary conditions: left, bottom, right, top
    T2[:, 0] = bdry1[0]
    T2[0, :] = bdry1[1]
    T2[:, -1] = bdry1[2]
    T2[-1, :] = bdry1[3]

# start while loop that ends when all the tempertures are changeing by a small amount
    start = time.time()
    for l in range(1, 10001):
        T1[:, :] = T2
        # Explicit Euler scheme
        for i in range(1, s+1):
            for j in range(1, s+1):
                T2[i, j] = (
                    T1[i, j]
                    + alpha * dt * (
                        (T1[i+1, j] - 2.0*T1[i, j] + T1[i-1, j]) * dx2
                        + (T1[i, j+1] - 2.0*T1[i, j] + T1[i, j-1]) * dy2
                    )
                    + S[i, j] * dt
                )
        k += 1
    end = time.time()
    timet=end - start
    #print(timet)
    return T2,k,timet
# some lookity look

