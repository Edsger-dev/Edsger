cimport numpy as np
import numpy as np

cdef DTYPE = np.float64
ctypedef np.float64_t DTYPE_t

cdef UITYPE = np.uint32
ctypedef np.uint32_t UITYPE_t

cdef DTYPE_t INFINITY = np.finfo(dtype=DTYPE).max

ctypedef enum NodeState:
    SCANNED, NOT_IN_HEAP, IN_HEAP