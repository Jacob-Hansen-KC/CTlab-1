# cython: boundscheck=False, wraparound=False, cdivision=True
import time
import numpy as np
cimport numpy as np
def Heat_Transfer_Cython(bdry1):

    cdef double t, alpha, dx, dy, dt, value
    cdef int s, k
    cdef np.ndarray[np.float64_t, ndim=1] bdry
    cdef np.ndarray[np.float64_t, ndim=2] T2, T1, S

    t = time.time()
    a = 97  # mm^2/s
    alpha = a / 1000**2  # m^2/s

    # area matrix, length, time parameters
    s = 50
    dx = 0.01
    dy = 0.01
    dt = 0.1
    value=1
    # initial temperature and heat source
    T2 = np.ones((s+2, s+2)) * 273.15  # K
    T1 = np.zeros((s+2, s+2))
    S = np.zeros((s+2, s+2))
    S[24, 24] = 100
    k = 0

    # boundary conditions: left, bottom, right, top
    bdry = bdry1
    T2[:, 0] = bdry[0]
    T2[0, :] = bdry[1]
    T2[:, -1] = bdry[2]
    T2[-1, :] = bdry[3]

    # main loop
    while 0.005 < value:
        T1 = T2.copy()
        # Explicit Euler scheme
        T2[1:-1, 1:-1] = (
            T1[1:-1, 1:-1]
            + alpha * dt * (
                (T1[2:, 1:-1] - 2*T1[1:-1, 1:-1] + T1[:-2, 1:-1]) / dx**2
                + (T1[1:-1, 2:] - 2*T1[1:-1, 1:-1] + T1[1:-1, :-2]) / dy**2
            )
            + S[1:-1, 1:-1] * dt
        )
        k += 1
        # reapply boundary conditions
        T2[:, 0] = bdry[0]
        T2[0, :] = bdry[1]
        T2[:, -1] = bdry[2]
        T2[-1, :] = bdry[3]
        value = np.abs(np.mean(T2 - T1))
    return k
    elapsed = time.time() - t

