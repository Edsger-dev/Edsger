import numpy as np
from timeit import default_timer
import psutil

DTYPE = np.float64
UITYPE = np.uint32
DTYPE_PY = DTYPE
UITYPE_PY = UITYPE
INFINITY = np.finfo(dtype=DTYPE).max
INFINITY_PY = INFINITY
N_THREADS = psutil.cpu_count()


class Timer(object):
    def __init__(self):
        self._timer = default_timer
    
    def __enter__(self):
        self.start()
        return self

    def __exit__(self, *args):
        self.stop()

    def start(self):
        """Start the timer."""
        self.start = self._timer()

    def stop(self):
        """Stop the timer. Calculate the interval in seconds."""
        self.end = self._timer()
        self.interval = self.end - self.start