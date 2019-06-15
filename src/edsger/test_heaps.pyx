
from priority_queue_binary_heap cimport *
from priority_queue_fibonacci_heap cimport *

import pandas as pd
from timeit import default_timer as timer
from libc.stdlib cimport malloc, free

import numpy as np
cimport numpy as np


cpdef test_bheap_init_01():

    cdef: 
        BinaryHeap bheap
        unsigned int l = 4, size_A = 0

    init_heap(&bheap, l)
    # print('INFINITY: ', INFINITY)

    assert bheap.length == l
    assert bheap.size == 0
    for i in range(l):
        print(bheap.nodes[i].key)
        assert bheap.nodes[i].state == 2
        assert bheap.nodes[i].tree_idx == l
    # for i in range(l+20):
    #     # try:
    #     print(bheap.A[i])
    #     # assert bheap.A[i] == l
    #     size_A += 1
    #     # except:
    #         # pass
    # # assert size_A == l


    free_heap(&bheap)




    # min_heap_insert(&bheap, 1, 3.0)
    # min_heap_insert(&bheap, 0, 2.0)
    # min_heap_insert(&bheap, 3, 4.0)
    # min_heap_insert(&bheap, 2, 1.0)
    # # for idx in range(4):
    #     # print(idx, bheap.nodes[idx].key, bheap.nodes[idx].state, bheap.nodes[idx].tree_idx)
    # # for i in range(4):
    # #     print(bheap.A[i])

    # print("size", bheap.size)

    # for i in range(4):
    #     print("current min value :", peek(&bheap))
    #     idx = extract_min(&bheap)
    #     print("exctracted node with index :", idx, ", key :", bheap.nodes[idx].key, "state :", bheap.nodes[idx].state, "tree_idx", bheap.nodes[idx].tree_idx)
    #     print("size", bheap.size)

    # min_heap_insert(&bheap, 1, 3.0)
    # min_heap_insert(&bheap, 0, 2.0)
    # min_heap_insert(&bheap, 3, 4.0)
    # min_heap_insert(&bheap, 2, 1.0)

    # print("size", bheap.size)

    # for i in range(4):
    #     if i == 2:
    #         decrease_key_from_node_index(&bheap, 3, 0.0)
    #     print("current min value :", peek(&bheap))
    #     idx = extract_min(&bheap)
    #     print("exctracted node with index :", idx, ", key :", bheap.nodes[idx].key, "state :", bheap.nodes[idx].state, "tree_idx", bheap.nodes[idx].tree_idx)
    #     print("size", bheap.size)
    
    free_heap(&bheap)




cpdef test_02():

# start = timer()
# end = timer()
# print "elapsed time: ", end - start

    cdef: 
        BinaryHeap bheap
        int N = 10
        int idx, min_idx

    np.random.seed(0)
    values = np.random.rand(N)

    start_t0 = timer()

    init_heap(&bheap, <unsigned int>N)

    end_t0 = timer()

    start_t1 = timer()


    end_t1 = timer()

    start_t2 = timer()

    for idx in range(N):
        min_heap_insert(&bheap, <unsigned int>idx, values[idx])

    end_t2 = timer()

    start_t3 = timer()

    for idx in range(N):
        decrease_key_from_node_index(&bheap, <unsigned int>idx, 0.5 * values[idx])

    end_t3 = timer()

    start_t4 = timer()

    while bheap.size > 0:
        min_idx = extract_min(&bheap)
        # print(bheap.nodes[min_idx].key)

    end_t4 = timer()

    start_t5 = timer()

    free_heap(&bheap)

    end_t5 = timer()

    print("init heap :", end_t0-start_t0)
    print("init nodes :", end_t1-start_t1)
    print("insert :", end_t2-start_t2)
    print("decrease key:", end_t3-start_t3)
    print("extract min :", end_t4-start_t4)
    print("free_heap :", end_t5-start_t5)

    print('done')


cpdef timing_measure(int N=10, int n_measures=10):
    
    cdef: 
        BinaryHeap bheap
        int idx, min_idx

    np.random.seed(0)
    values = np.random.rand(N+n_measures)

    # init_heap
    start_t0 = timer()
    init_heap(&bheap, <unsigned int>N+n_measures)
    end_t0 = timer()
    t0 = end_t0 - start_t0

    # min_heap_insert
    for idx in range(N):
        min_heap_insert(&bheap, <unsigned int>idx, values[idx])
    start_t1 = timer()
    for idx in range(N, N+n_measures):
        min_heap_insert(&bheap, <unsigned int>idx, values[idx])
    end_t1 = timer()
    t1 = (end_t1 - start_t1) / n_measures

    # decrease_key
    start_t2 = timer()
    for idx in range(N, N+n_measures):
        decrease_key_from_node_index(&bheap, <unsigned int>idx, 0.1 * values[idx])
    end_t2 = timer()
    t2 = (end_t2 - start_t2) / n_measures

    # find min
    start_t3 = timer()
    for i in range(n_measures):
        min = peek(&bheap)
    end_t3 = timer()
    t3 = (end_t3 - start_t3) / n_measures    

    # extract_min
    start_t4 = timer()
    for i in range(n_measures):
        min_idx = extract_min(&bheap)
    end_t4 = timer()
    t4 = (end_t4 - start_t4) / n_measures

    # free_heap
    start_t5 = timer()
    free_heap(&bheap)
    end_t5 = timer()
    t5 = end_t5 - start_t5

    df = pd.DataFrame({"heap_size": N,
                       "init_heap": t0,
                       "insert_node": t1,
                       "decrease_key": t2,
                       "find_min": t3,
                       "extract_min": t4,
                       "free_heap": t5}, index=[0])

    return df


cpdef timing_measure_fib(int N=10, int n_measures=10):
    
    cdef: 
        int idx, min_idx
        FibonacciHeap heap
        FibonacciNode *hnode
        FibonacciNode *hnodes = <FibonacciNode*> malloc((N+n_measures) * sizeof(FibonacciNode))

    np.random.seed(0)
    values = np.random.rand(N+n_measures)

    # init_heap
    start_t0 = timer()
    for i in range(N+n_measures):
        initialize_node(&hnodes[i], i, values[i])
    end_t0 = timer()
    t0 = end_t0 - start_t0

    heap.min_node = NULL

    # min_heap_insert
    for idx in range(N):
        insert_node(&heap, &hnodes[idx])
    start_t1 = timer()
    for idx in range(N, N+n_measures):
        insert_node(&heap, &hnodes[idx])
    end_t1 = timer()
    t1 = (end_t1 - start_t1) / n_measures

    # decrease_key
    start_t2 = timer()
    for idx in range(N, N+n_measures):
        decrease_val(&heap, &hnodes[idx], 0.1 * values[idx])
    end_t2 = timer()
    t2 = (end_t2 - start_t2) / n_measures


    # find min
    start_t3 = timer()
    for i in range(n_measures):
        min = heap.min_node.val
    end_t3 = timer()
    t3 = (end_t3 - start_t3) / n_measures    

    # extract_min
    start_t4 = timer()
    for i in range(n_measures):
        hnode = remove_min(&heap)
    end_t4 = timer()
    t4 = (end_t4 - start_t4) / n_measures

    # free_heap
    start_t5 = timer()
    free(hnodes)
    end_t5 = timer()
    t5 = end_t5 - start_t5

    df = pd.DataFrame({"heap_size": N,
                       "init_heap": t0,
                       "insert_node": t1,
                       "decrease_key": t2,
                       "find_min": t3,
                       "extract_min": t4,
                       "free_heap": t5}, index=[0])

    return df



cpdef test_is_empty():

    cdef: 
        BinaryHeap bheap
        unsigned int idx

    init_heap(&bheap, 1)

    assert bheap.length == 1
    assert bheap.size == 0
    assert is_empty(&bheap)
    min_heap_insert(&bheap, 0, 3.0)
    assert bheap.length == 1
    assert bheap.size == 1
    assert not is_empty(&bheap)
    idx = extract_min(&bheap)
    assert bheap.length == 1
    assert bheap.size == 0
    assert is_empty(&bheap) 

    free_heap(&bheap)


cpdef test_peek():

    cdef: 
        BinaryHeap bheap

    k = 4
    init_heap(&bheap, k)
    min_val = 2.0
    for i in range(k):
        min_heap_insert(&bheap, i, min_val)
        assert peek(&bheap) == min_val
        min_val -= 1.0
    min_val += 1.0
    for i in range(k-1):
        idx = extract_min(&bheap)
        min_val += 1.0
        assert peek(&bheap) == min_val

    free_heap(&bheap)


# cpdef test_decrease():
    
#     cdef: 
#         BinaryHeap bheap


#     init_heap(&bheap, 4)
#     min_heap_insert(&bheap, 0, 3.0)
#     assert bheap.nodes[0].state == IN_HEAP
#     assert bheap.nodes[1].state == NOT_IN_HEAP
#     assert bheap.nodes[2].state == NOT_IN_HEAP
#     assert bheap.nodes[3].state == NOT_IN_HEAP
#     min_heap_insert(&bheap, 1, 2.0)
#     assert bheap.nodes[0].state == IN_HEAP
#     assert bheap.nodes[1].state == IN_HEAP
#     assert bheap.nodes[2].state == NOT_IN_HEAP
#     assert bheap.nodes[3].state == NOT_IN_HEAP
#     min_heap_insert(&bheap, 2, 1.0)
#     assert bheap.nodes[0].state == IN_HEAP
#     assert bheap.nodes[1].state == IN_HEAP
#     assert bheap.nodes[2].state == IN_HEAP
#     assert bheap.nodes[3].state == NOT_IN_HEAP
#     assert bheap.length == 4
#     assert bheap.size == 3
#     assert peek(&bheap) == 1.0
#     decrease_key_from_node_index(&bheap, 0, 0.0)
#     assert peek(&bheap) == 0.0
#     idx = extract_min(&bheap)
#     assert idx == 0
#     assert peek(&bheap) == 1.0
#     assert bheap.nodes[0].key == 0.0
#     assert bheap.nodes[0].state == SCANNED
#     assert bheap.nodes[1].state == IN_HEAP
#     assert bheap.nodes[2].state == IN_HEAP
#     assert bheap.nodes[3].state == NOT_IN_HEAP
#     decrease_key_from_node_index(&bheap, 1,  0.0)
#     decrease_key_from_node_index(&bheap, 2, -1.0)
#     assert peek(&bheap) == -1.0
#     assert bheap.nodes[1].key ==  0.0
#     assert bheap.nodes[2].key == -1.0
#     decrease_key_from_node_index(&bheap, 1, -2.0)
#     assert peek(&bheap) == -2.0
#     assert bheap.nodes[1].key == -2.0
#     assert bheap.nodes[2].key == -1.0
#     idx = extract_min(&bheap)
#     assert idx == 1
#     assert peek(&bheap) == -1.0
#     assert bheap.nodes[0].state == SCANNED
#     assert bheap.nodes[1].state == SCANNED
#     assert bheap.nodes[2].state == IN_HEAP
#     assert bheap.nodes[3].state == NOT_IN_HEAP

#     free_heap(&bheap)


def memory_usage_psutil():
    # return the memory usage in MB
    import os,  psutil
    process = psutil.Process(os.getpid())
    mem = process.memory_full_info().uss / float(1 << 20)
    return mem

cpdef mem_meas_01(int N=10):
    import sys

    cdef: 
        BinaryHeap bheap
        # NodeState state = SCANNED

    init_heap(&bheap, N)

    # print(memory_usage_psutil())

    # print("key", sys.getsizeof(bheap.nodes[0].key))
    # print("state", sys.getsizeof(bheap.nodes[0].state))
    # print("tree_idx", sys.getsizeof(bheap.nodes[0].tree_idx))
    # print("node", sys.getsizeof(bheap.nodes[0]))
    # print("nodes", N * sizeof(Node))
    # print("A", N * sizeof(unsigned int))

    
    
    free_heap(&bheap)


