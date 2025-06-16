# To install packages, run these commands in your terminal, not in a Python script:
import time
t = time.time()
import numpy as np
import matplotlib.pyplot as plt

# Define thermal diffusivity (aluminum)
a = 97  # mm^2/s
alpha = a / 1000**2  # m^2/s

# Define area matrix, length, time parameters
s = 50  # grid size
dx = 0.01
dy = 0.01
Lx = np.arange(0, (s-1)*dx + dx, dx)
Ly = np.arange(0, (s-1)*dy + dy, dy)
X, Y = np.meshgrid(Lx, Ly)
dt = 0.1

# Initial temperature and heat source
T2 = np.ones((s+2, s+2)) * 273.15  # K
T1 = np.zeros((s+2, s+2))
S = np.zeros((s+2, s+2))
S[s//2, s//2] = 100  # heat source at center

# Boundary conditions: left, bottom, right, top
bdry = [500, 300, 200, 700]
T2[:, 0] = bdry[0]
T2[0, :] = bdry[1]
T2[:, -1] = bdry[2]
T2[-1, :] = bdry[3]
k = 0
value = 1
fig, ax = plt.subplots()
cb = None

def plot_heat():
    global cb
    ax.clear()
    cax = ax.contourf(
        Lx, Ly, T2[1:-1, 1:-1], 20, cmap='jet',
        vmin=min(bdry), vmax=max(bdry)
    )
    ax.set_xlabel('X (m)')
    ax.set_ylabel('Y (m)')
    ax.set_title(f"{k*dt:.1f} (Sec)")
    # Remove previous colorbar if it exists
    #if cb is not None:
        #cb.remove()
    #cb = plt.colorbar(cax, ax=ax)
    #cb.set_label('Temperature (K)')


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
    if k % 10 == 0:
        plot_heat()
        plt.pause(0.0000000000000000000000000000001)

# Show the final plot after the loop
plot_heat()
plt.show(block=False)
plt.close()
elapsed = time.time() - t
print(elapsed)

