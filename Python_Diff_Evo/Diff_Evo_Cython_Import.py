
import time
import Diff_Evo_Cython_3
import numpy as np
total=0
start = time.time()
for i in range(100):
    count=Diff_Evo_Cython_3.Diff_Evo_Cython()
    #total=count+total
end = time.time()
elapsed = end - start
print(elapsed, "seconds")
print(count)
ips= elapsed /100/count
print(ips, "seconds per iteration")