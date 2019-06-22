cimport numpy as np
import numpy as np

cdef DTYPE = np.float64
ctypedef np.float64_t DTYPE_t

cdef DTYPE_t INFINITY 

ctypedef enum NodeState:
    SCANNED = 1
    NOT_IN_HEAP = 2
    IN_HEAP = 3