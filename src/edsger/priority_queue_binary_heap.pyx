
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
    4          2          0          3          1         <-- tree index

    We assume the following :
    key_2 <= key_1
    key_2 <= key_4
    key_4 <= key_3
    key_4 <= key_0

    Tree array :
    ------------

    0   1   2   3   4  <-- tree index
    2 | 4 | 1 | 3 | 0  <-- node index


    tree indices :

            0
           / \
          1   2
         / \
        3   4
    
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

# import numpy as np
# cimport numpy as np
# cdef DTYPE_t INFINITY = np.finfo(dtype=DTYPE).max

from libc.stdlib cimport malloc, free


cdef void init_heap(
    BinaryHeap* bheap,
    unsigned int length) nogil:
    """Initialize the binary heap.

    input
    =====
    * BinaryHeap* bheap : binary heap
    * unsigned int length : length (maximum size) of the binary heap
    """
    cdef unsigned int i

    bheap.length = length
    bheap.size = 0
    bheap.A = <unsigned int*> malloc(length * sizeof(unsigned int))
    bheap.nodes = <Node*> malloc(length * sizeof(Node))
    for i in range(length):
        bheap.A[i] = length
        _initialize_node(bheap, i)


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
    unsigned int node_idx) nogil:
    """Initialize a single node of the heap.

    input
    =====
    * BinaryHeap* bheap : binary heap
    * unsigned int node_idx : node index
    """
    bheap.nodes[node_idx].key = INFINITY
    bheap.nodes[node_idx].state = NOT_IN_HEAP
    bheap.nodes[node_idx].tree_idx = bheap.length


cdef void min_heap_insert(
    BinaryHeap* bheap,
    unsigned int node_idx,
    DTYPE_t key) nogil:
    """Insert a Node into the heap and reorder the heap.

    input
    =====
    * BinaryHeap* bheap : binary heap
    * unsigned int node_idx : index of the node in the node array
    * DTYPE_t key : key value of the Node

    assumptions
    ===========
    * node bheap.nodes[node_idx] is not in the heap
    * key is smaller than INFINITY
    """
    cdef unsigned int tree_idx = bheap.size

    bheap.size += 1
    bheap.nodes[node_idx].key = INFINITY
    bheap.nodes[node_idx].state = IN_HEAP
    bheap.nodes[node_idx].tree_idx = tree_idx
    bheap.A[bheap.size-1] = node_idx
    _decrease_key_from_tree_index(bheap, tree_idx, key)


cdef void decrease_key_from_node_index(
    BinaryHeap* bheap, 
    unsigned int node_idx, 
    DTYPE_t key_new) nogil:
    """Decrease the key of a node in the heap, given its node index.

    input
    =====
    * BinaryHeap* bheap : binary heap
    * unsigned int node_idx : index of the node in the node array
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
    return bheap.nodes[bheap.A[0]].key


cdef bint is_empty(BinaryHeap* bheap) nogil:
    """Check whether the queue has no elements.

    input
    =====
    * BinaryHeap* bheap : binary heap 
    """
    cdef bint isempty = 0

    if bheap.size == 0:
        isempty = 1

    return isempty


cdef unsigned int extract_min(BinaryHeap* bheap) nogil:
    """Extract heap min.

    input
    =====
    * BinaryHeap* bheap : binary heap

    output
    ======
    * unsigned int : min node index

    assumption
    ==========
    * bheap.size > 0
    """
    cdef unsigned int node_idx

    # update min node' state
    bheap.nodes[bheap.A[0]].state = SCANNED

    # exchange the root of the tree with the last heap element
    _exchange_nodes(bheap, 0, bheap.size-1)

    # get the min node index
    node_idx = bheap.A[bheap.size-1]

    # remove this node from the heap
    bheap.nodes[node_idx].tree_idx = bheap.length  # reset tree index
    bheap.A[bheap.size-1] = bheap.length  # reset tree array value
    bheap.size -= 1

    # reorder the tree elements
    _min_heapify(bheap, 0)

    return node_idx


cdef unsigned int _parent(unsigned int i) nogil:
    """Get the tree index of the parent node.

    input
    =====
    unsigned int i: tree index

    assumption
    ==========
    * i > 0
    """
    return (i - 1) // 2


cdef unsigned int _left_child(unsigned int i) nogil:
    """Returns the left child node.

    input
    =====
    * unsigned int i : tree index
    """
    return 2 * i + 1


cdef unsigned int _right_child(unsigned int i) nogil:
    """Returns the right child node.

    input
    =====
    * unsigned int i : tree index
    """
    return 2 * (i + 1)


cdef void _exchange_nodes(
    BinaryHeap* bheap, 
    unsigned int i,
    unsigned int j) nogil:
    """Exchange two nodes in the heap.

    input
    =====
    * BinaryHeap* bheap: binary heap
    * unsigned int i: first heap array index
    * unsigned int j: second heap array index
    """
    cdef: 
        unsigned int a_i = bheap.A[i]
        unsigned int a_j = bheap.A[j]
    
    # exchange node indices in the heap array
    bheap.A[i] = a_j
    bheap.A[j] = a_i

    # exchange tree indices in the node array
    bheap.nodes[a_j].tree_idx = i
    bheap.nodes[a_i].tree_idx = j


cdef void _min_heapify(
    BinaryHeap* bheap, 
    unsigned int tree_idx) nogil:
    """Re-order sub-tree under a given node (given its tree index) 
    until it satisfies the heap property.

    Note that this function is rcursive.

    input
    =====
    * BinaryHeap* bheap : binary heap
    * unsigned int tree_idx : tree index
    """
    cdef: 
        unsigned int l, r, s = tree_idx, node_idx
    
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
    unsigned int tree_idx, 
    DTYPE_t key_new) nogil:
    """Decrease the key of a node in the heap, given its tree index.

    input
    =====
    * BinaryHeap* bheap : binary heap
    * unsigned int tree_idx : tree index

    assumptions
    ===========
    * bheap.nodes[bheap.A[i]] is in the heap (i < bheap.size)
    * key_new < bheap.nodes[bheap.A[i]].key
    """
    cdef unsigned int i = tree_idx

    bheap.nodes[bheap.A[i]].key = key_new
    while i > 0: 
        if bheap.nodes[bheap.A[_parent(i)]].key > bheap.nodes[bheap.A[i]].key:
            _exchange_nodes(bheap, i, _parent(i))
            i = _parent(i)
        else:
            break