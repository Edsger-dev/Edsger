
""" Priority queue based on a minimum binary heap, 
    focusing on time not memory efficiency.
    Binary heap implemented with a static array.
    Tree nodes also stored in a static array.

    Node array :
    ------------

    0          1          3          4          5         <-- node index
    Node_0   | Node_1   | Node_2   | Node_3   | Node_4
    key_0      key_1      key_2      key_3      key_4     <-- key
    IN_HEAP    IN_HEAP    IN_HEAP    IN_HEAP    IN_HEAP   <-- state
    5          3          1          4          2         <-- tree index

    We assume the following :
    key_2 <= key_1
    key_2 <= key_4
    key_4 <= key_3
    key_4 <= key_0

    Tree array :
    ------------

    1   2   3   4   5  <-- tree index
    2 | 4 | 1 | 3 | 0  <-- node index


    tree indices :

            1
           / \
          2   3
         / \
        4   5
    
    node indices :

            2
           / \
          4   1
         / \
        3   0
 
    Author: François Pacull
"""

# COMPILER DIRECTIVES
#cython: boundscheck=False, wraparound=False, embedsignature=True
#cython: cdivision=True, initializedcheck=False
# COMPILER DIRECTIVES

from libc.stdlib cimport malloc, free
from edsger.commons cimport UITYPE_t

cimport edsger.commons as commons
from cython.parallel import prange

cdef void init_heap(
    BinaryHeap* bheap,
    UITYPE_t length,
    int num_threads) nogil:
    """Initialize the binary heap.

    input
    =====
    * BinaryHeap* bheap : binary heap
    * UITYPE_t length : length (maximum size) of the binary heap
    """
    cdef: 
        int i  # array index
        UITYPE_t idx

    bheap.length = length
    bheap.size = 0
    bheap.A = <UITYPE_t*> malloc((length + 1) * sizeof(UITYPE_t))
    bheap.nodes = <Node*> malloc(length * sizeof(Node))

    bheap.A[0] = length
    for i in prange(
        length, 
        schedule=guided, 
        nogil=True, 
        num_threads=num_threads):
        idx = <UITYPE_t>i
        bheap.A[idx + 1] = length
        _initialize_node(bheap, <UITYPE_t>idx)


cdef void free_heap(
    BinaryHeap* bheap) nogil:
    """Free the binary heap.

    input
    =====
    * BinaryHeap* bheap : binary heap
    """
    free(bheap.A)
    free(bheap.nodes)


cdef void _initialize_node(
    BinaryHeap* bheap,
    UITYPE_t node_idx) nogil:
    """Initialize a single node of the heap.

    input
    =====
    * BinaryHeap* bheap : binary heap
    * intp_t node_idx : node array index
    """
    bheap.nodes[node_idx].key = commons.INFINITY
    bheap.nodes[node_idx].state = commons.NOT_IN_HEAP
    bheap.nodes[node_idx].tree_idx = bheap.length + 1


cdef void min_heap_insert(
    BinaryHeap* bheap,
    UITYPE_t node_idx,
    DTYPE_t key) nogil:
    """Insert a Node into the heap and reorder the heap.

    input
    =====
    * BinaryHeap* bheap : binary heap
    * UITYPE_t node_idx : index of the node in the node array
    * DTYPE_t key : key value of the Node

    assumptions
    ===========
    * node bheap.nodes[node_idx] is not in the heap
    * key is smaller than INFINITY
    """
    cdef UITYPE_t tree_idx = bheap.size + 1

    bheap.size += 1
    bheap.nodes[node_idx].key = commons.INFINITY
    bheap.nodes[node_idx].state = commons.IN_HEAP
    bheap.nodes[node_idx].tree_idx = tree_idx
    bheap.A[tree_idx] = node_idx
    _decrease_key_from_tree_index(bheap, tree_idx, key)


cdef void decrease_key_from_node_index(
    BinaryHeap* bheap, 
    UITYPE_t node_idx, 
    DTYPE_t key_new) nogil:
    """Decrease the key of a node in the heap, given its node index.

    input
    =====
    * BinaryHeap* bheap : binary heap
    * UITYPE_t node_idx : index of the node in the node array
    * DTYPE_t key_new : new value of the node key 

    assumption
    ==========
    * bheap.nodes[idx] is in the heap
    """
    _decrease_key_from_tree_index(
        bheap, 
        bheap.nodes[node_idx].tree_idx, 
        key_new)


cdef DTYPE_t peek(BinaryHeap* bheap) nogil:
    """Find heap min.

    input
    =====
    * BinaryHeap* bheap : binary heap

    output
    ======
    * DTYPE_t : key value of the min node

    assumption
    ==========
    * bheap.size > 0
    * heap is heapified
    """
    return bheap.nodes[bheap.A[1]].key


cdef bint is_empty(BinaryHeap* bheap) nogil:
    """Check whether the queue has no element.

    input
    =====
    * BinaryHeap* bheap : binary heap 
    """
    cdef bint isempty = 0

    if bheap.size == 0:
        isempty = 1

    return isempty


cdef UITYPE_t extract_min(BinaryHeap* bheap) nogil:
    """Extract heap min.

    input
    =====
    * BinaryHeap* bheap : binary heap

    output
    ======
    * UITYPE_t : min node index

    assumption
    ==========
    * bheap.size > 0
    """
    cdef: 
        UITYPE_t node_idx
        UITYPE_t i = bheap.size

    # update min node' state
    bheap.nodes[bheap.A[1]].state = commons.SCANNED

    # exchange the root of the tree with the last heap element
    _exchange_nodes(bheap, 1, i)

    # get the min node index
    node_idx = bheap.A[i]

    # remove this node from the heap
    bheap.nodes[node_idx].tree_idx = bheap.length + 1  # reset tree index
    bheap.A[i] = bheap.length  # reset tree array value
    bheap.size -= 1

    # reorder the tree elements
    _min_heapify(bheap, 1)

    return node_idx


cdef UITYPE_t _parent(UITYPE_t i) nogil:
    """Get the tree index of the parent node.

    input
    =====
    UITYPE_t i: tree index

    assumption
    ==========
    * i > 0
    """
    return i // 2


cdef UITYPE_t _left_child(UITYPE_t i) nogil:
    """Returns the left child node.

    input
    =====
    * UITYPE_t i : tree index
    """
    return 2 * i


cdef UITYPE_t _right_child(UITYPE_t i) nogil:
    """Returns the right child node.

    input
    =====
    * UITYPE_t i : tree index
    """
    return 2 * i + 1


cdef void _exchange_nodes(
    BinaryHeap* bheap, 
    UITYPE_t i,
    UITYPE_t j) nogil:
    """Exchange two nodes in the heap.

    input
    =====
    * BinaryHeap* bheap: binary heap
    * UITYPE_t i: first heap array index
    * UITYPE_t j: second heap array index
    """
    cdef: 
        UITYPE_t a_i = bheap.A[i]
        UITYPE_t a_j = bheap.A[j]
    
    # exchange node indices in the heap array
    bheap.A[i] = a_j
    bheap.A[j] = a_i

    # exchange tree indices in the node array
    bheap.nodes[a_j].tree_idx = i
    bheap.nodes[a_i].tree_idx = j


cdef void _min_heapify(
    BinaryHeap* bheap, 
    UITYPE_t tree_idx) nogil:
    """Re-order sub-tree under a given node (given its tree index) 
    until it satisfies the heap property.

    Note that this function is rcursive.

    input
    =====
    * BinaryHeap* bheap : binary heap
    * UITYPE_t tree_idx : tree index
    """
    cdef: 
        UITYPE_t l, r, s = tree_idx, node_idx
    
    node_idx = bheap.A[s]

    l = _left_child(s)
    r = _right_child(s)

    if l < bheap.size:
        if bheap.nodes[bheap.A[l]].key < bheap.nodes[node_idx].key:
            s = l

    if r < bheap.size:
        node_idx = bheap.A[s]
        if bheap.nodes[bheap.A[r]].key < bheap.nodes[node_idx].key:
            s = r

    if s != tree_idx:
        _exchange_nodes(bheap, tree_idx, s)
        _min_heapify(bheap, s)


cdef void _decrease_key_from_tree_index(
    BinaryHeap* bheap, 
    UITYPE_t tree_idx, 
    DTYPE_t key_new) nogil:
    """Decrease the key of a node in the heap, given its tree index.

    input
    =====
    * BinaryHeap* bheap : binary heap
    * UITYPE_t tree_idx : tree index

    assumptions
    ===========
    * bheap.nodes[bheap.A[i]] is in the heap (i < bheap.size)
    * key_new < bheap.nodes[bheap.A[i]].key
    """
    cdef UITYPE_t i = tree_idx

    bheap.nodes[bheap.A[i]].key = key_new
    while i > 1: 
        if bheap.nodes[bheap.A[_parent(i)]].key > bheap.nodes[bheap.A[i]].key:
            _exchange_nodes(bheap, i, _parent(i))
            i = _parent(i)
        else:
            break