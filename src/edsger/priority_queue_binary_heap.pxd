from edsger.commons cimport DTYPE_t, NodeState

# tree node
cdef struct Node:
    DTYPE_t key
    NodeState state
    unsigned int tree_idx

# priority queue
cdef struct BinaryHeap:
    unsigned int length  # number of elements in the array
    unsigned int size  # number of elements in the heap, stored within the array
    unsigned int* A  # array storing the binary tree
    Node* nodes  # array storing the nodes

cdef void init_heap(BinaryHeap*, unsigned int) nogil
cdef void free_heap(BinaryHeap*) nogil
cdef void min_heap_insert(BinaryHeap*, unsigned int, DTYPE_t key) nogil
cdef void decrease_key_from_node_index(BinaryHeap*, unsigned int, DTYPE_t) nogil
cdef DTYPE_t peek(BinaryHeap*) nogil
cdef bint is_empty(BinaryHeap* bheap) nogil
cdef unsigned int extract_min(BinaryHeap*) nogil