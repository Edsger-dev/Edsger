from setuptools import setup, find_packages, Extension
from codecs import open  # To use a consistent encoding
from Cython.Build import cythonize
import numpy

requirements = ["cython", "numpy", "pandas"]
setup_requirements = ["cython", "numpy"]
test_requirements = ["pytest"]

# Get the licence
with open("LICENSE") as f:
    license = f.read()

extra_compile_args = ["-Ofast"]

extensions = [
    Extension("edsger.commons", ["src/edsger/commons.pyx"]),
    Extension(
        "edsger.priority_queue_binary_heap",
        ["src/edsger/priority_queue_binary_heap.pyx"],
        extra_compile_args=extra_compile_args,
    ),
    Extension(
        "edsger.priority_queue_fibonacci_heap",
        ["src/edsger/priority_queue_fibonacci_heap.pyx"],
        extra_compile_args=extra_compile_args,
    ),
    Extension("edsger.test_heaps", ["src/edsger/test_heaps.pyx"]),
    Extension(
        "edsger.priority_queue_timings", ["src/edsger/priority_queue_timings.pyx"]
    ),
]

setup(
    name="Edsger",
    version="0.0.1",
    description="Static user equilibrium assignment",
    author="Edsger devs",
    author_email="pacullfrancois@gmail.com",
    license=license,
    package_dir={"edsger": "src/edsger"},
    package_data={
        "edsger.commons": ["src/edsger/commons.pxd"],
        "edsger.priority_queue_binary_heap": [
            "src/edsger/priority_queue_binary_heap.pxd"
        ],
        "edsger.priority_queue_fibonacci_heap": [
            "src/edsger/priority_queue_fibonacci_heap.pxd"
        ],
        "edsger.priority_queue_timings": ["src/edsger/priority_queue_timings"],
        "edsger.test_heaps": ["src/edsger/test_heaps"],
    },
    ext_modules=cythonize(
        extensions,
        compiler_directives={"language_level": "3"},
        include_path=["src/edsger/"],
    ),
    install_requires=requirements,
    setup_requires=setup_requirements,
    tests_require=test_requirements,
    extras_require={"test": test_requirements},
    include_dirs=[numpy.get_include()],
    packages=find_packages(),
)
