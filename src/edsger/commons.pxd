cimport numpy as np
import numpy as np

cdef DTYPE
ctypedef np.float64_t DTYPE_t

cdef UITYPE
ctypedef np.uint32_t UITYPE_t

cdef DTYPE_t INFINITY

ctypedef enum NodeState:
    SCANNED, NOT_IN_HEAP, IN_HEAP