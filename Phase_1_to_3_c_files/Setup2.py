from setuptools import setup, Extension
from Cython.Build import cythonize
import numpy

extensions = [
    Extension(
        "Heat_Transfer_Cython_4",
        ["c:/Users/Jacob/Python/Scripts/CTlab/Phase_1_to_3_c_files/Heat_Transfer_Cython_4.pyx"],
        extra_compile_args=["-O3", "-march=native", "-mtune=native","-g"],
        extra_link_args=["-O3", "-march=native", "-mtune=native","-g"],
        include_dirs=[numpy.get_include()],
    )
]

setup(
    ext_modules=cythonize(extensions),
)
# use this command in the terminal to compile the c files into .pyd files
# python c:/Users/Jacob/Python/Scripts/CTlab/Phase_1_to_3_c_files/Setup2.py build_ext --inplace
# python c:/Users/Jacob/Python/Scripts/CTlab/Phase_1_to_3_c_files/Setup2.py build_ext --inplace --compiler=mingw32