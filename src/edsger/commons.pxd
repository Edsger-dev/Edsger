cimport numpy as cnp

cdef DTYPE
ctypedef cnp.float64_t DTYPE_t

cdef UITYPE
ctypedef cnp.uint32_t UITYPE_t

cdef DTYPE_t INFINITY

ctypedef enum NodeState:
    SCANNED, NOT_IN_HEAP, IN_HEAP

cdef int N_THREADS