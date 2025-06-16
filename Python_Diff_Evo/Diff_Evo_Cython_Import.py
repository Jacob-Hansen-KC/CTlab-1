
import time
import Diff_Evo_Cython_2
import numpy as np
total=0
start = time.time()
for i in range(100):
    count=Diff_Evo_Cython_2.Diff_Evo_Cython()
    total=count+total
end = time.time()
print(end - start, "seconds")
print(total)