from setuptools import setup, find_packages, Extension
from codecs import open  # To use a consistent encoding
from Cython.Build import cythonize

requirements = ["cython", "numpy", "pandas"]
setup_requirements = ["cython", "numpy"]
test_requirements = ["pytest"]

# Get the licence
with open("LICENSE") as f:
    license = f.read()

extra_compile_args = ["-Ofast"]

extensions = [
    Extension("commons", ["src/edsger/commons.pyx"]),
    Extension(
        "priority_queue_binary_heap",
        ["src/edsger/priority_queue_binary_heap.pyx"],
        extra_compile_args=extra_compile_args,
    ),
    Extension(
        "priority_queue_fibonacci_heap",
        ["src/edsger/priority_queue_fibonacci_heap.pyx"],
        extra_compile_args=extra_compile_args,
    ),
    Extension("test_heaps", ["src/edsger/test_heaps.pyx"]),
    Extension("priority_queue_timings", ["src/edsger/priority_queue_timings.pyx"]),
]

setup(
    name="Edsger",
    version="0.0.0",
    description="Static user equilibrium assignment",
    author="Edsger devs",
    author_email="pacullfrancois@gmail.com",
    license=license,
    package_dir={"edsger": "src/edsger"},
    package_data={
        "commons": ["src/edsger/commons.pxd"],
        "priority_queue_binary_heap": ["src/edsger/priority_queue_binary_heap.pxd"],
        "priority_queue_fibonacci_heap": [
            "src/edsger/priority_queue_fibonacci_heap.pxd"
        ],
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
)
