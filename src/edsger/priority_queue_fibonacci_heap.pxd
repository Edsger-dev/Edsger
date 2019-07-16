import numpy as np
cimport numpy as np

DTYPE = np.float64
ctypedef np.float64_t DTYPE_t

cdef enum NodeState:
   SCANNED = 1
   NOT_IN_HEAP = 2
   IN_HEAP = 3

# FibonacciNode structure #
# ----------------------- #

#  This structure and the operations on it are the nodes of the
#  Fibonacci heap.

cdef struct FibonacciNode:
    unsigned int index
    unsigned int rank
    NodeState state
    DTYPE_t val
    FibonacciNode* parent
    FibonacciNode* left_sibling
    FibonacciNode* right_sibling
    FibonacciNode* children

cdef void initialize_node(FibonacciNode*, unsigned int, double) nogil
cdef FibonacciNode* rightmost_sibling(FibonacciNode*) nogil
cdef FibonacciNode* leftmost_sibling(FibonacciNode*) nogil
cdef void add_child(FibonacciNode*, FibonacciNode*) nogil
cdef void add_sibling(FibonacciNode*, FibonacciNode*) nogil
cdef void remove(FibonacciNode*) nogil

# FibonacciHeap structure #
# ----------------------- #

#  This structure and operations on it use the FibonacciNode
#  routines to implement a Fibonacci heap

ctypedef FibonacciNode* pFibonacciNode

cdef struct FibonacciHeap:
    FibonacciNode* min_node
    pFibonacciNode[100] roots_by_rank  # maximum number of nodes is ~2^100.

cdef void insert_node(FibonacciHeap*, FibonacciNode*) nogil
cdef void decrease_val(FibonacciHeap*, FibonacciNode*, DTYPE_t) nogil
cdef void link(FibonacciHeap*, FibonacciNode*) nogil
cdef FibonacciNode* remove_min(FibonacciHeap*) nogil