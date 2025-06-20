import time
import Heat_Transfer_Cython_3
import numpy as np
bound=np.array([500,300,200,700], dtype=np.float64)
start = time.time()
#for i in range(1):
T2 = Heat_Transfer_Cython_3.Heat_Transfer_Cython(bound)
end = time.time()
print(end - start, "seconds")
print(T2)

