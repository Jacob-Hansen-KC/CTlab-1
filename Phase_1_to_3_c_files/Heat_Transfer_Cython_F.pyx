# cython: boundscheck=False, wraparound=False, cdivision=True
import numpy as np
cimport numpy as np

def Heat_Transfer_Cython(np.ndarray[np.float64_t, ndim=1] bdry):
    cdef double alpha = 97.0 / 1_000_000.0  # m^2/s
    cdef int s = 20, k
    cdef double dx = 0.01, dy = 0.01, dt = 0.1
    cdef np.ndarray[np.float64_t, ndim=2] T2 = np.ones((s+2, s+2), dtype=np.float64) * 273.15
    cdef np.ndarray[np.float64_t, ndim=2] T1 = np.zeros((s+2, s+2), dtype=np.float64)
    cdef np.ndarray[np.float64_t, ndim=2] S = np.zeros((s+2, s+2), dtype=np.float64)
    S[11, 2] = 10.0

    # boundary conditions: left, bottom, right, top
    T2[:, 0] = bdry[0]
    T2[0, :] = bdry[1]
    T2[:, -1] = bdry[2]
    T2[-1, :] = bdry[3]

    for k in range(1200):
        T1[:, :] = T2
        # Explicit Euler scheme (vectorized)
        T2[1:-1, 1:-1] = (
            T1[1:-1, 1:-1]
            + alpha * dt * (
                (T1[2:, 1:-1] - 2.0 * T1[1:-1, 1:-1] + T1[:-2, 1:-1]) / dx**2
                + (T1[1:-1, 2:] - 2.0 * T1[1:-1, 1:-1] + T1[1:-1, :-2]) / dy**2
            )
            + S[1:-1, 1:-1] * dt
        )
        # reapply boundary conditions
        T2[:, 0] = bdry[0]
        T2[0, :] = bdry[1]
        T2[:, -1] = bdry[2]
        T2[-1, :] = bdry[3]
    return T2