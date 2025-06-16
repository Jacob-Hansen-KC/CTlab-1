# filepath: [Setup.py](http://_vscodecontentref_/1)
from setuptools import setup
from Cython.Build import cythonize
import numpy

setup(
    #ext_modules=cythonize(r".venv/Scripts/CTLABS/C_Zone/Phase_Three_Cython_2.pyx"),
    ext_modules=cythonize(r".venv/Scripts/CTLABS/C_Zone/Heat_Transfer_Cython_2.pyx"),
    #ext_modules=cythonize(r".venv/Scripts/CTLABS/C_Zone/Diff_Evo_Cython_2.pyx"),
    include_dirs=[numpy.get_include()],
)

# python .venv/Scripts/CTLABS/C_Zone/Setup.py build_ext --inplace