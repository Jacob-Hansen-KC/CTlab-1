import time
import Heat_Transfer_Cython_2
import numpy as np
bound=np.array([500,300,200,700], dtype=np.float64)
start = time.time()
for i in range(10):
    T2 = Heat_Transfer_Cython_2.Heat_Transfer_Cython(bound)
end = time.time()
print(end - start, "seconds")

