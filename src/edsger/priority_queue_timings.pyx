# COMPILER DIRECTIVES
#cython: boundscheck=False, wraparound=False, embedsignature=True
#cython: cdivision=True, initializedcheck=False
# COMPILER DIRECTIVES

cimport numpy as np
import numpy as np
from libc.stdlib cimport malloc, free

from commons import Timer
cimport commons
from priority_queue_binary_heap cimport *
from priority_queue_fibonacci_heap cimport *

cdef sort(unsigned int n=100, seed=124):
    cdef: 
        BinaryHeap bheap
        unsigned int i

    np.random.seed(seed)
    values = np.random.rand(n)

    time = {}

    timer = Timer()
    timer.start()
    sorted_values = np.empty(n)
    init_heap(&bheap, n)
    for i in range(n):
        min_heap_insert(&bheap, i, values[i])
    for i in range(n):
        sorted_values[i] = bheap.nodes[extract_min(&bheap)].key
    free_heap(&bheap)
    timer.stop()
    time['bheap'] = timer.interval

    sorted_ref = np.copy(sorted_values)

    timer = Timer()
    timer.start()
    sorted_values = np.empty(n)

    cdef:
        FibonacciHeap heap
        FibonacciNode *hnode
        FibonacciNode *hnodes = <FibonacciNode*> malloc(n * sizeof(FibonacciNode))

    heap.min_node = NULL
    for i in range(n):
        initialize_node(&hnodes[i], i, values[i])
        insert_node(&heap, &hnodes[i])
    for i in range(n):
        hnode = remove_min(&heap)
        sorted_values[i] = hnode.val

    free(hnodes)
    timer.stop()
    time['fheap'] = timer.interval

    assert np.array_equal(sorted_values, sorted_ref)

    for algo in ['quicksort', 'mergesort', 'heapsort']:
        timer = Timer()
        timer.start()
        sorted_values = np.sort(values, kind=algo)
        timer.stop()
        time[algo] = timer.interval
        assert np.array_equal(sorted_values, sorted_ref)

    return time


cpdef sort_compare(n=100, seed=124):
    time = sort(n, seed)
    return time
