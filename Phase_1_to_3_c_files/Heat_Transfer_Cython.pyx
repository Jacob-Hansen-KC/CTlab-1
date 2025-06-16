import time
import numpy as np
cimport numpy as np
def Heat_Transfer_Cython(bdry1):

    cdef double t, alpha, dx, dy, dt, value
    cdef int s, k
    cdef np.ndarray Lx, Ly, X, Y, T2, T1, S, bdry

    t = time.time()

    # Define area matrix, length, time parameters
    s = 50  # grid size
    dx = 0.01
    dy = 0.01
    dt = 0.1
    
    Lx = np.arange(0, (s-1)*dx + dx, dx)
    Ly = np.arange(0, (s-1)*dy + dy, dy)
    X, Y = np.meshgrid(Lx, Ly)

    # Initial temperature and heat source
    T2 = np.ones((s+2, s+2)) * 273.15  # K
    T1 = np.zeros((s+2, s+2))
    S = np.zeros((s+2, s+2))
    # Boundary conditions: left, bottom, right, top
    bdry = bdry1

    # Define thermal diffusivity (aluminum)
    a = 97  # mm^2/s
    alpha = 97 / 1000**2  # m^2/s

    S[25, 25] = 100  # heat source at center

    T2[:, 0] = bdry[0]
    T2[0, :] = bdry[1]
    T2[:, -1] = bdry[2]
    T2[-1, :] = bdry[3]
    k = 0
    value = 1
    while value > 0.005:
        T1 = T2.copy()
        T2[1:-1, 1:-1] = (
            T1[1:-1, 1:-1]
            + alpha * dt * (
                (T1[2:, 1:-1] - 2 * T1[1:-1, 1:-1] + T1[:-2, 1:-1]) / dx**2
                + (T1[1:-1, 2:] - 2 * T1[1:-1, 1:-1] + T1[1:-1, :-2]) / dy**2
            )
            + S[1:-1, 1:-1] * dt
        )
        k += 1
        T2[:, 0] = bdry[0]
        T2[0, :] = bdry[1]
        T2[:, -1] = bdry[2]
        T2[-1, :] = bdry[3]
        value = np.abs(np.mean(T2 - T1))

    elapsed = time.time() - t
    print(elapsed)
    return T2
