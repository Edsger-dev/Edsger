"""
Temporary setup file for the priority queue.

python setup.py build_ext --inplace
"""
import numpy
from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

ext_modules=[
    Extension("commons", ["commons.pyx"]),
    Extension("priority_queue_binary_heap", ["priority_queue_binary_heap.pyx"]),
    Extension("priority_queue_fibonacci_heap", ["priority_queue_fibonacci_heap.pyx"]),
    Extension("test_heaps", ["test_heaps.pyx"]),
    Extension("sort_timings", ["sort_timings.pyx"]),
]
setup(
    ext_modules=cythonize(ext_modules, compiler_directives={'language_level' : "3"}),
    include_dirs=[numpy.get_include()],
)
