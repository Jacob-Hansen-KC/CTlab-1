import time
from Heat_Transfer_Func import Heat_Transfer_Func
t = time.time()
import numpy as np
import matplotlib.pyplot as plt

# --- Differential Evolution Setup ---
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
F = 0.8
a = np.zeros(dim)
b = np.zeros(dim)
c = np.zeros(dim)
s = 10
count = 0
cost2 = 1
cost3 = 1
costlist = []

# Initial plot
plt.ion()
fig, ax = plt.subplots()
ax.plot(one, NP[0, :], 'k.', one*2, NP[1, :], 'r.', one*3, NP[2, :], 'b.', one*4, NP[3, :], 'g.')
ax.set_xlim([0, dim+1])
ax.set_ylim([low, high])
ax.grid(True, which='both')
ax.set_title(f'{count} iterations')
ax.set_ylabel('Temperature (K)')
ax.set_xlabel('Dimensions')
ax.legend(['left', 'bottom', 'right', 'top'])
plt.show()
plt.pause(0.000000000000000000000000000001)

# --- Differential Evolution Loop ---
while cost2 > 0.01 or cost3 > 0.05:
    count += 1
    x = np.random.permutation(NP.shape[1])[:5]
    for k in range(len(x)):
        NP2 = NP.copy()
        NP2 = np.delete(NP2, x[k], axis=1)
        idx = np.random.permutation(NP2.shape[1])[:dim*3]
        for l in range(dim):
            r = l*3
            a[l] = NP2[l, idx[r]]
            b[l] = NP2[l, idx[r+1]]
            c[l] = NP2[l, idx[r+2]]
        y = np.zeros(dim)
        for i in range(dim):
            r = np.random.rand()
            if r < CR or i == N[i]:
                y[i] = a[i] + F * (b[i] - c[i])
            else:
                y[i] = NP[i, x[k]]
        # Run the heat transfer code for the new value
        T1 = Heat_Transfer_Func(y)
        K1 = [T1[5,5], T1[18,15], T1[16,9], T1[8,16]]
        # Calculate value of the cost function for each set
        new = (K1[0]-277)**2 + (K1[1]-283)**2 + (K1[2]-280)**2 + (K1[3]-280)**2
        old = (NPstore[0, x[k]]-277)**2 + (NPstore[1, x[k]]-283)**2 + (NPstore[2, x[k]]-280)**2 + (NPstore[3, x[k]]-280)**2
        if new < old:
            NP[:, x[k]] = y
            NPstore[:, x[k]] = K1
    if count > 500:
        s = 10
        if count > 1000:
            s = 10
    if count % s == 0:
        ax.clear()
        ax.plot(one, NP[0, :], 'k.', one*2, NP[1, :], 'r.', one*3, NP[2, :], 'b.', one*4, NP[3, :], 'm.')
        ax.set_xlim([0, dim+1])
        ax.set_ylim([low, high])
        ax.grid(True, which='both')
        ax.set_title(f'{count} Iterations')
        ax.set_ylabel('Temperature (K)')
        ax.set_xlabel('Dimensions')
        ax.legend(['Left Boundary', 'Bottom Boundary', 'Right Boundary', 'Top Boundary'])
        plt.pause(0.000000000000000000000000001)
    cost2 = np.mean((NPstore[0, :]-277)**2 + (NPstore[1, :]-283)**2 + (NPstore[2, :]-280)**2 + (NPstore[3, :]-280)**2)
    cost3 = np.mean(np.std(NP, axis=1))
    costlist.append(cost2)

result = np.mean(NP, axis=1)
print("Result:", result)

# --- Final Heat Transfer Visualization ---
s = 20
dx = dy = 0.01
dt = 0.1
Lx = np.arange(0, (s-1)*dx+dx, dx)
Ly = np.arange(0, (s-1)*dy+dy, dy)
X, Y = np.meshgrid(Lx, Ly)
T2 = np.ones((s+2, s+2)) * 273.15
S = np.zeros((s+2, s+2))
S[12, 3] = 10
bdry = result
T2[:, 0] = bdry[0]
T2[0, :] = bdry[1]
T2[:, -1] = bdry[2]
T2[-1, :] = bdry[3]
k = 0
plt.figure()
while k < 1200:
    T1 = T2.copy()
    T2[1:-1, 1:-1] = (
        T1[1:-1, 1:-1]
        + (97/1000**2) * dt * (
            (T1[2:, 1:-1] - 2*T1[1:-1, 1:-1] + T1[:-2, 1:-1]) / dx**2
            + (T1[1:-1, 2:] - 2*T1[1:-1, 1:-1] + T1[1:-1, :-2]) / dy**2
        )
        + S[1:-1, 1:-1] * dt
    )
    T2[:, 0] = bdry[0]
    T2[0, :] = bdry[1]
    T2[:, -1] = bdry[2]
    T2[-1, :] = bdry[3]
    k += 1
    if k % 10 == 0:
        plt.clf()
        plt.contourf(Lx, Ly, T2[1:-1, 1:-1], 20, cmap='jet', vmin=min(bdry), vmax=max(bdry))
        plt.title(f"{k*dt:.1f} (Sec)")
        plt.colorbar(label='Temperature (K)')
        plt.xlabel('X (m)')
        plt.ylabel('Y (m)')
        plt.pause(0.00000000000000000000000000001)
plt.show()

# --- Plot cost function progress ---
plt.figure()
plt.loglog(range(15, len(costlist)+1), costlist[14:])
plt.xlabel('Iteration')
plt.ylabel('Average cost function value')
plt.title('Progress over iterations')
plt.show()
elapsed = time.time() - t
print(elapsed)