cimport numpy as cnp

from edsger.commons cimport DTYPE_t, UITYPE_t, NodeState

# tree node
cdef struct Node:
    DTYPE_t key
    NodeState state
    UITYPE_t tree_idx

# priority queue
cdef struct BinaryHeap:
    UITYPE_t length  # number of elements in the array
    UITYPE_t size  # number of elements in the heap, stored within the array
    UITYPE_t* A  # array storing the binary tree
    Node* nodes  # array storing the nodes

cdef void init_heap(BinaryHeap*, UITYPE_t, int) nogil
cdef void free_heap(BinaryHeap*) nogil
cdef void min_heap_insert(BinaryHeap*, UITYPE_t, DTYPE_t key) nogil
cdef void decrease_key_from_node_index(BinaryHeap*, UITYPE_t, DTYPE_t) nogil
cdef DTYPE_t peek(BinaryHeap*) nogil
cdef bint is_empty(BinaryHeap* bheap) nogil
cdef UITYPE_t extract_min(BinaryHeap*) nogil