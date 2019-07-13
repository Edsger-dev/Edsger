from setuptools import setup, find_packages, Extension
from codecs import open  # To use a consistent encoding
from Cython.Build import cythonize

requirements = ["cython", "numpy", "pandas"]
setup_requirements = ["cython", "numpy"]
test_requirements = ["pytest"]

include_dirs = []
try:
    import numpy

    include_dirs += [numpy.get_include()]
except:
    pass

# Get the licence
with open("LICENSE") as f:
    license = f.read()

extensions = [
    Extension("commons.*", ["src/edsger/commons.pyx"]),
    # Extension("priority_queue_binary_heap.*", ["src/edsger/priority_queue_binary_heap.pyx"]),
    # Extension("priority_queue_fibonacci_heap", ["priority_queue_fibonacci_heap.pyx"]),
    # Extension("test_heaps", ["test_heaps.pyx"]),
    # Extension("priority_queue_timings", ["priority_queue_timings.pyx"]),
]

setup(
    name="Edsger",
    version="0.0.0",
    description="Static user equilibrium assignment",
    author="Edsger devs",
    author_email="pacullfrancois@gmail.com",
    license=license,
    extras_require={"test": test_requirements},
    package_dir={"": "src"},
    packages=find_packages(where="src"),
    package_data={
        "commons": ["*.pxd"], 
        "priority_queue_binary_heap": ["*.pxd"]},
    ext_modules=cythonize(extensions, compiler_directives={"language_level": "3"}),
    install_requires=requirements,
    setup_requires=setup_requirements,
    tests_require=test_requirements,
    include_dirs=include_dirs,
    include_package_data=True,
    # Note that zip_safe needs to be false in order for the pxd files to be available to cython cimport
    zip_safe=False,
)
