# For compiling in Linux
from setuptools import setup, Extension
from Cython.Build import cythonize
import numpy
import os
os.environ["CC"] = "icx" #icx
os.environ["CXX"] = "icpx"  #icpx
extensions = [
    Extension(
        "Heat_Transfer_Cython_5",
        ["/mnt/c/Users/Jacob/Python/Scripts/CTlab/Phase_1_to_3_c_files/Heat_Transfer_Cython_5.pyx"],
        extra_compile_args=["-O3", "-march=native"],
        extra_link_args=[],
        include_dirs=[numpy.get_include()],
    )
]

setup(
    ext_modules=cythonize(extensions,annotate=True),
)
# use this command in the terminal to compile the c files into .pyd files
#export CC=gcc
# python3 Phase_1_to_3_c_files/Setup3.py build_ext --inplace
#mingw32" "-O3", "-march=native", "-mtune=native","-g"

#intel# "-O3", "-march=native"
