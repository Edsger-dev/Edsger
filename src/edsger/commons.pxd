import numpy as np
cimport numpy as np

cdef DTYPE = np.float64
ctypedef np.float64_t DTYPE_t
global DTYPE
global DTYPE_t

cdef DTYPE_t INFINITY 
global INFINITY

ctypedef enum NodeState:
    SCANNED = 1
    NOT_IN_HEAP = 2
    IN_HEAP = 3