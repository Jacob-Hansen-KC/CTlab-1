import time
import Heat_Transfer_Numba_2
import numpy as np
bound=np.array([500,200,300,700], dtype=np.float64)
start = time.time()
#for i in range(1):
T2 = Heat_Transfer_Numba_2.Heat_Transfer_Func(bound)
end = time.time()
print(end - start, "seconds")

