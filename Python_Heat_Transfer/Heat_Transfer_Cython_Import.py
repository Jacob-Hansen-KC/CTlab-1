import time
import Heat_Transfer_Cython_4 as Heat_Transfer_Cython
import numpy as np
bound=np.array([500,200,300,700], dtype=np.float64)
start = time.time()
#for i in range(1):
T2,k= Heat_Transfer_Cython.Heat_Transfer_Cython(bound)
end = time.time()
print(end - start, "seconds")
#for row in T2:
    #print(row)
print(k)
