cimport numpy as np
import numpy as np
# import pandas as pd
# from timeit import default_timer as timer
# from libc.stdlib cimport malloc, free

cimport edsger.commons as commons
from edsger.priority_queue_binary_heap cimport *
from edsger.priority_queue_fibonacci_heap cimport *


cpdef bheap_init(unsigned int l=4):
    """ Testing the initialization of a binary heap.

    A small heap is created. Then we check the values
    of the empty heap.
    """

    cdef BinaryHeap bheap

    init_heap(&bheap, l, 1)

    assert bheap.length == l
    assert bheap.size == 0
    for i in range(l):
        assert bheap.A[i] == l
        assert bheap.nodes[i].key == commons.INFINITY
        assert bheap.nodes[i].state == commons.NOT_IN_HEAP
        assert bheap.nodes[i].tree_idx == l

    free_heap(&bheap)

    return True


cpdef bheap_insert_01():
    """ Testing a single insertion into an empty binary heap 
    of length 1.
    """

    cdef BinaryHeap bheap

    init_heap(&bheap, 1, 1)
    min_heap_insert(&bheap, 0, 1.0)
    assert bheap.length == 1
    assert bheap.size == 1
    assert bheap.A[0] == 0
    assert bheap.nodes[0].key == 1.0
    assert bheap.nodes[0].state == commons.IN_HEAP
    assert bheap.nodes[0].tree_idx == 0

    free_heap(&bheap)

    return True


cpdef bheap_insert_02():
    """ Creating a heap of length 4 ad inserting 3 nodes.
    """

    cdef BinaryHeap bheap

    init_heap(&bheap, 4, 1)
    min_heap_insert(&bheap, 3, 3.0)
    min_heap_insert(&bheap, 0, 2.0)
    min_heap_insert(&bheap, 2, 1.0)

    assert bheap.length == 4
    assert bheap.size == 3

    assert bheap.A[0] == 2
    assert bheap.A[1] != bheap.A[2]
    assert bheap.A[1] in [0, 3]
    assert bheap.A[2] in [0, 3]
    assert bheap.A[3] == 4

    assert bheap.nodes[0].key == 2.0
    assert bheap.nodes[0].state == commons.IN_HEAP
    assert bheap.nodes[0].tree_idx in [1, 2]
    assert bheap.nodes[1].key == commons.INFINITY
    assert bheap.nodes[1].state == commons.NOT_IN_HEAP
    assert bheap.nodes[1].tree_idx == 4 
    assert bheap.nodes[2].key == 1.0
    assert bheap.nodes[2].state == commons.IN_HEAP
    assert bheap.nodes[2].tree_idx == 0
    assert bheap.nodes[3].key == 3.0
    assert bheap.nodes[3].state == commons.IN_HEAP
    assert bheap.nodes[3].tree_idx in [1, 2]

    free_heap(&bheap)

    return True


cpdef bheap_insert_03(n=4):
    """ Inserting nodes with identical keys.
    """
    cdef: 
        BinaryHeap bheap
        size_t i

    init_heap(&bheap, n, 1)
    for i in range(n):
        min_heap_insert(&bheap, i, 1.0)
    for i in range(n):
        assert bheap.A[i] == i

    free_heap(&bheap)

    return True


cpdef bheab_decrease():
    """ Creating a binary heap of length 4, inserting 4 nodes and 
    decreasing the key of 2 nodes.
    """

    cdef BinaryHeap bheap

    init_heap(&bheap, 4, 1)
    min_heap_insert(&bheap, 3, 3.0)
    min_heap_insert(&bheap, 0, 2.0)
    min_heap_insert(&bheap, 2, 1.0)    
    decrease_key_from_node_index(&bheap, 3, 0.5)
    decrease_key_from_node_index(&bheap, 0, 0.0)
    min_heap_insert(&bheap, 1, 2.0)

    assert bheap.length == 4
    assert bheap.size == 4

    assert bheap.A[0] == 0
    assert bheap.A[1] != bheap.A[2]
    assert bheap.A[1] in [2, 3]
    assert bheap.A[2] in [2, 3]
    assert bheap.A[3] == 1
    assert bheap.nodes[0].key == 0.0
    assert bheap.nodes[1].key == 2.0
    assert bheap.nodes[2].key == 1.0
    assert bheap.nodes[3].key == 0.5
    for i in range(4):
        assert bheap.nodes[i].state == commons.IN_HEAP
        assert bheap.nodes[bheap.A[i]].tree_idx == i  # similar to: assert bheap.A[bheap.nodes[i].tree_idx] == i

    free_heap(&bheap)

    return True


cpdef bheap_peek():

    cdef BinaryHeap bheap

    init_heap(&bheap, 4, 1)
    min_heap_insert(&bheap, 0, 3.0)
    min_heap_insert(&bheap, 1, 2.0)
    min_heap_insert(&bheap, 2, 1.0)
    assert peek(&bheap) == 1.0
    assert bheap.nodes[bheap.A[0]].key == 1.0

    free_heap(&bheap)

    return True


cpdef bheap_is_empty():

    cdef BinaryHeap bheap

    init_heap(&bheap, 1, 1)

    assert is_empty(&bheap) == 1
    min_heap_insert(&bheap, 0, 1.0)
    assert is_empty(&bheap) == 0
    assert extract_min(&bheap) == 0
    assert is_empty(&bheap) == 1

    free_heap(&bheap)

    return True


cpdef bheap_extract():

    cdef BinaryHeap bheap

    init_heap(&bheap, 2, 1)

    min_heap_insert(&bheap, 0, 1.0)
    min_heap_insert(&bheap, 1, 2.0)

    assert bheap.size == 2
    assert peek(&bheap) == 1.0
    assert extract_min(&bheap) == 0
    assert bheap.nodes[0].state == commons.SCANNED
    assert bheap.size == 1
    assert peek(&bheap) == 2.0    
    assert extract_min(&bheap) == 1
    assert bheap.nodes[1].state == commons.SCANNED
    assert bheap.size == 0

    free_heap(&bheap)

    return True


cpdef sort(n=100, seed=124):
    
    cdef: 
        BinaryHeap bheap
        size_t i

    init_heap(&bheap, n, 1)
    np.random.seed(seed)
    values = np.random.rand(n)

    sorted_values = np.zeros(n)
    for i in range(n):
        min_heap_insert(&bheap, <unsigned int>i, <commons.DTYPE_t> values[i])
    for i in range(n):
        sorted_values[i] = bheap.nodes[extract_min(&bheap)].key

    sorted_ref = np.sort(values)  # kind : {‘quicksort’, ‘mergesort’, ‘heapsort’, ‘stable’}, Default is ‘quicksort’.
    assert np.array_equal(sorted_values, sorted_ref)

    free_heap(&bheap)

    return True


# def memory_usage_psutil():
#     # return the memory usage in MB
#     import os,  psutil
#     process = psutil.Process(os.getpid())
#     mem = process.memory_full_info().uss / float(1 << 20)
#     return mem

# cpdef mem_meas_01(int N=10):
#     import sys

#     cdef: 
#         BinaryHeap bheap
#         # NodeState state = SCANNED

#     init_heap(&bheap, N)

#     # print(memory_usage_psutil())

#     # print("key", sys.getsizeof(bheap.nodes[0].key))
#     # print("state", sys.getsizeof(bheap.nodes[0].state))
#     # print("tree_idx", sys.getsizeof(bheap.nodes[0].tree_idx))
#     # print("node", sys.getsizeof(bheap.nodes[0]))
#     # print("nodes", N * sizeof(Node))
#     # print("A", N * sizeof(unsigned int))

    
    
#     free_heap(&bheap)


