# import libraries
from Phase_Three_Cython_3 import Phase_Three_Cython
import numpy as np
import time

# define the inputs for the Phase Three Cython function
X2 = np.array([9, 39, 11, 33], dtype=np.int32)
Y2 = np.array([38, 40, 14, 6], dtype=np.int32)
#bound = np.array([277, 283, 280, 280], dtype=np.float64)
bound = np.array([425, 369, 326, 282], dtype=np.float64)

#run the Phase Three Cython function while timing it
start_time = time.time()
result, result2, count = Phase_Three_Cython(bound, X2, Y2)
end_time = time.time()

# print various results
print("Time taken:", end_time - start_time, "seconds")
print("Final Boundary Conditions:", result)
print("Result:", result2)
print("Iterations:", count)
ips = (end_time - start_time)/count
print("Seconds per iteration:", ips)
