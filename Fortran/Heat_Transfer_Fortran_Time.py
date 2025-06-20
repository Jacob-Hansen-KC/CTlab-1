#This script is used to run the Fortran code and time it
# Import libraries
import subprocess
import time
#run the Fortran code and time it
start = time.time()
result = subprocess.run(['C:\\Users\\Jacob\\Python\\heat_equation.exe'], capture_output=True, text=True)
end = time.time()
# print various results
print(end - start, "seconds")
print(result.stdout)  # Output from the Fortran program