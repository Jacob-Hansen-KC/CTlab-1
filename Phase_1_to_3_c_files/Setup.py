# Import libraries
# This script is used to compile the Cython files into shared object files that can be imported
from setuptools import setup
from Cython.Build import cythonize
import numpy
# use setup to complile the .pyx files. 
# alternate files commented out for ease of swap between files
setup(
    ext_modules=cythonize("c:/Users/Jacob/Python/Scripts/CTlab/Phase_1_to_3_c_files/Phase_Three_Cython_3.pyx"),
    #ext_modules=cythonize("c:/Users/Jacob/Python/Scripts/CTlab/Phase_1_to_3_c_files/Heat_Transfer_Cython_3.pyx"),
    #ext_modules=cythonize("c:/Users/Jacob/Python/Scripts/CTlab/Phase_1_to_3_c_files/Diff_Evo_Cython_3.pyx"),
    include_dirs=[numpy.get_include()],
)
# use this command in the terminal to compile the c files into .pyd files
# python c:/Users/Jacob/Python/Scripts/CTlab/Phase_1_to_3_c_files/Setup.py build_ext --inplace