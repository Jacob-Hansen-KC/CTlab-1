from setuptools import setup, Extension
from Cython.Build import cythonize
import numpy

extensions = [
    Extension(
        "Heat_Transfer_Cython_5",
        ["c:/Users/Jacob/Python/Scripts/CTlab/Phase_1_to_3_c_files/Heat_Transfer_Cython_5.pyx"],
        extra_compile_args=["-O3", "-march=native", "-mtune=native","-g"],
        extra_link_args=[],
        include_dirs=[numpy.get_include()],
    )
]

setup(
    ext_modules=cythonize(extensions),
)
# use this command in the terminal to compile the c files into .pyd files

# python c:/Users/Jacob/Python/Scripts/CTlab/Phase_1_to_3_c_files/Setup2.py build_ext --inplace --compiler=mingw32
#mingw32# "-O3", "-march=native", "-mtune=native","-g"
#intel# "/O3" , "/arch:CORE-AVX2"
#MSVC# "/O2", "/arch:AVX2"