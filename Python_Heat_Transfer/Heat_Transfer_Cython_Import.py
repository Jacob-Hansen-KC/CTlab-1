import time
import Heat_Transfer_Cython_5 as Heat_Transfer_Cython
import numpy as np
bound=np.array([500,200,300,700], dtype=np.float64)
start = time.time()
#for i in range(1):
T2,k,timet= Heat_Transfer_Cython.Heat_Transfer_Cython()
end = time.time()
print(timet, "seconds")
#np.savetxt("T2_output.csv", T2, delimiter=",", fmt="%.2f")
#print("Saved to T2_output.csv")
#for row in T2:
    #print(row)
print(k)
