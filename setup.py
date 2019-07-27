from setuptools import setup, find_packages, Extension
from codecs import open  # To use a consistent encoding
from Cython.Build import cythonize
import numpy
import os
import re

requirements = ["cython", "numpy", "pandas", "scipy"]
setup_requirements = ["cython", "numpy"]
test_requirements = ["pytest"]

here = os.path.abspath(os.path.dirname(__file__))


def read(*parts):
    with open(os.path.join(here, *parts), "r") as fp:
        return fp.read()


def find_version(*file_paths):
    version_file = read(*file_paths)
    version_match = re.search(r"^__version__ = ['\"]([^'\"]*)['\"]", version_file, re.M)
    if version_match:
        return version_match.group(1)
    raise RuntimeError("Unable to find version string.")


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
    Extension("edsger.sssp", ["src/edsger/sssp.pyx"]),
]

setup(
    name="Edsger",
    version=find_version("src", "edsger", "__init__.py"),
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
        "edsger.sssp": ["src/edsger/sssp"],
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
