import time
from Heat_Transfer_Cython_T import Heat_Transfer_Cython as heat_transfer
import numpy as np
cimport numpy as np
# --- Differential Evolution Setup --
# Define bounds and critical variables
def Phase_Three_Cython(val):
    cdef double low, high, CR, F, cost2, cost3, t, r, z, new, old, alpha, dx, dy, dt, value2
    cdef int dim, count, i, l, k, s, kk
    cdef np.ndarray NP, NPD, NPstore, a, b, c, N, one, x, y, idx, result, K1, T1,value,Lx, Ly, X, Y, T2, Tk, S, bdry
    t = time.time()
    value=val
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
    F = 0.7
    a = np.zeros(dim)
    b = np.zeros(dim)
    c = np.zeros(dim)
    count = 0
    cost2 = 1
    cost3 = 1
    # Define area matrix, length, time parameters for heat transfer
    s = 20  # grid size
    dx = 0.01
    dy = 0.01
    dt = 0.1
    
    Lx = np.arange(0, (s-1)*dx + dx, dx)
    Ly = np.arange(0, (s-1)*dy + dy, dy)
    X, Y = np.meshgrid(Lx, Ly)

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

            Lx = np.arange(0, (s-1)*dx + dx, dx)
            Ly = np.arange(0, (s-1)*dy + dy, dy)
            X, Y = np.meshgrid(Lx, Ly)

    # Initial temperature and heat source
            T2 = np.ones((s+2, s+2)) * 273.15  # K
            T1 = np.zeros((s+2, s+2))
            S = np.zeros((s+2, s+2))
            # Boundary conditions: left, bottom, right, top
            bdry = y

    # Define thermal diffusivity (aluminum)
            alpha = 97 / 1000**2  # m^2/s
      
            S[12, 3] = 10

            T2[:, 0] = bdry[0]
            T2[0, :] = bdry[1]
            T2[:, -1] = bdry[2]
            T2[-1, :] = bdry[3]
            kk = 0
            value2 = 1
            while kk<1200:
                Tk = T2.copy()
                T2[1:-1, 1:-1] = (
                    Tk[1:-1, 1:-1]
                    + alpha * dt * (
                        (Tk[2:, 1:-1] - 2 * Tk[1:-1, 1:-1] + Tk[:-2, 1:-1]) / dx**2
                        + (Tk[1:-1, 2:] - 2 * Tk[1:-1, 1:-1] + Tk[1:-1, :-2]) / dy**2
                    )
                    + S[1:-1, 1:-1] * dt
                )
                kk += 1
                T2[:, 0] = bdry[0]
                T2[0, :] = bdry[1]
                T2[:, -1] = bdry[2]
                T2[-1, :] = bdry[3]
                value2 = np.abs(np.mean(T2 - Tk))
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
        #print(cost2)

    result = np.mean(NP, axis=1)
    result2= np.mean(NPstore, axis=1)
    print("Final Boundary Conditions:", result)
    print("Result:", result2)
    elapsed = time.time() - t
    print(elapsed)
    print(count)