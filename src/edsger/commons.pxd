cimport numpy as np
import numpy as np

cdef DTYPE = np.float64
ctypedef np.float64_t DTYPE_t


cdef DTYPE_t INFINITY = np.finfo(dtype=DTYPE).max


ctypedef enum NodeState:
    SCANNED, NOT_IN_HEAP, IN_HEAP