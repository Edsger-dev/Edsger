# import pandas as pd
# from timeit import default_timer as timer
# from libc.stdlib cimport malloc, free

from priority_queue_binary_heap cimport *
from priority_queue_fibonacci_heap cimport *
cimport commons


cpdef test_bheap_init_01(unsigned int l=4):
    """ Testing the initialization of a binary heap.

    A small heap is created. Then we check the values
    of the empty heap.
    """

    cdef BinaryHeap bheap

    init_heap(&bheap, l)

    assert bheap.length == l
    assert bheap.size == 0
    for i in range(l):
        assert bheap.A[i] == l
        assert bheap.nodes[i].key == commons.INFINITY
        assert bheap.nodes[i].state == commons.NOT_IN_HEAP
        assert bheap.nodes[i].tree_idx == l

    free_heap(&bheap)


cpdef test_bheap_insert_01():
    """ Testing a single insertion into an empty binary heap 
    of length 1.
    """

    cdef BinaryHeap bheap

    init_heap(&bheap, 1)
    min_heap_insert(&bheap, 0, 1.0)
    assert bheap.length == 1
    assert bheap.size == 1
    assert bheap.A[0] == 0
    assert bheap.nodes[0].key == 1.0
    assert bheap.nodes[0].state == commons.IN_HEAP
    assert bheap.nodes[0].tree_idx == 0

    free_heap(&bheap)


cpdef test_bheap_insert_02():
    """ Creating a heap of length 4 ad inserting 3 nodes.
    """

    cdef BinaryHeap bheap

    init_heap(&bheap, 4)
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


cpdef test_bheab_decrease_01():
    """ Creating a binary heap of length 4, inserting 4 nodes and 
    decreasing the key of 2 nodes.
    """

    cdef BinaryHeap bheap

    init_heap(&bheap, 4)
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


cpdef test_bheap_peek_01():

    cdef BinaryHeap bheap

    init_heap(&bheap, 4)
    min_heap_insert(&bheap, 0, 3.0)
    min_heap_insert(&bheap, 1, 2.0)
    min_heap_insert(&bheap, 2, 1.0)
    assert peek(&bheap) == 1.0
    assert bheap.nodes[bheap.A[0]].key == 1.0

    free_heap(&bheap)


cpdef test_bheap_is_empty_01():

    cdef BinaryHeap bheap

    init_heap(&bheap, 1)

    assert is_empty(&bheap) == 1
    min_heap_insert(&bheap, 0, 1.0)
    assert is_empty(&bheap) == 0
    assert extract_min(&bheap) == 0
    assert is_empty(&bheap) == 1

    free_heap(&bheap)


cpdef test_bheap_extract_01():

    cdef BinaryHeap bheap

    init_heap(&bheap, 2)

    min_heap_insert(&bheap, 0, 1.0)
    min_heap_insert(&bheap, 1, 2.0)

    assert bheap.size == 2
    assert peek(&bheap) == 1.0
    assert extract_min(&bheap) == 0
    assert bheap.size == 1
    assert peek(&bheap) == 2.0    
    assert extract_min(&bheap) == 1
    assert bheap.size == 0

    free_heap(&bheap)



# cpdef test_02():

# # start = timer()
# # end = timer()
# # print "elapsed time: ", end - start

#     cdef: 
#         BinaryHeap bheap
#         int N = 10
#         int idx, min_idx

#     np.random.seed(0)
#     values = np.random.rand(N)

#     start_t0 = timer()

#     init_heap(&bheap, <unsigned int>N)

#     end_t0 = timer()

#     start_t1 = timer()


#     end_t1 = timer()

#     start_t2 = timer()

#     for idx in range(N):
#         min_heap_insert(&bheap, <unsigned int>idx, values[idx])

#     end_t2 = timer()

#     start_t3 = timer()

#     for idx in range(N):
#         decrease_key_from_node_index(&bheap, <unsigned int>idx, 0.5 * values[idx])

#     end_t3 = timer()

#     start_t4 = timer()

#     while bheap.size > 0:
#         min_idx = extract_min(&bheap)
#         # print(bheap.nodes[min_idx].key)

#     end_t4 = timer()

#     start_t5 = timer()

#     free_heap(&bheap)

#     end_t5 = timer()

#     print("init heap :", end_t0-start_t0)
#     print("init nodes :", end_t1-start_t1)
#     print("insert :", end_t2-start_t2)
#     print("decrease key:", end_t3-start_t3)
#     print("extract min :", end_t4-start_t4)
#     print("free_heap :", end_t5-start_t5)

#     print('done')


# cpdef timing_measure(int N=10, int n_measures=10):
    
#     cdef: 
#         BinaryHeap bheap
#         int idx, min_idx

#     np.random.seed(0)
#     values = np.random.rand(N+n_measures)

#     # init_heap
#     start_t0 = timer()
#     init_heap(&bheap, <unsigned int>N+n_measures)
#     end_t0 = timer()
#     t0 = end_t0 - start_t0

#     # min_heap_insert
#     for idx in range(N):
#         min_heap_insert(&bheap, <unsigned int>idx, values[idx])
#     start_t1 = timer()
#     for idx in range(N, N+n_measures):
#         min_heap_insert(&bheap, <unsigned int>idx, values[idx])
#     end_t1 = timer()
#     t1 = (end_t1 - start_t1) / n_measures

#     # decrease_key
#     start_t2 = timer()
#     for idx in range(N, N+n_measures):
#         decrease_key_from_node_index(&bheap, <unsigned int>idx, 0.1 * values[idx])
#     end_t2 = timer()
#     t2 = (end_t2 - start_t2) / n_measures

#     # find min
#     start_t3 = timer()
#     for i in range(n_measures):
#         min = peek(&bheap)
#     end_t3 = timer()
#     t3 = (end_t3 - start_t3) / n_measures    

#     # extract_min
#     start_t4 = timer()
#     for i in range(n_measures):
#         min_idx = extract_min(&bheap)
#     end_t4 = timer()
#     t4 = (end_t4 - start_t4) / n_measures

#     # free_heap
#     start_t5 = timer()
#     free_heap(&bheap)
#     end_t5 = timer()
#     t5 = end_t5 - start_t5

#     df = pd.DataFrame({"heap_size": N,
#                        "init_heap": t0,
#                        "insert_node": t1,
#                        "decrease_key": t2,
#                        "find_min": t3,
#                        "extract_min": t4,
#                        "free_heap": t5}, index=[0])

#     return df


# cpdef timing_measure_fib(int N=10, int n_measures=10):
    
#     cdef: 
#         int idx, min_idx
#         FibonacciHeap heap
#         FibonacciNode *hnode
#         FibonacciNode *hnodes = <FibonacciNode*> malloc((N+n_measures) * sizeof(FibonacciNode))

#     np.random.seed(0)
#     values = np.random.rand(N+n_measures)

#     # init_heap
#     start_t0 = timer()
#     for i in range(N+n_measures):
#         initialize_node(&hnodes[i], i, values[i])
#     end_t0 = timer()
#     t0 = end_t0 - start_t0

#     heap.min_node = NULL

#     # min_heap_insert
#     for idx in range(N):
#         insert_node(&heap, &hnodes[idx])
#     start_t1 = timer()
#     for idx in range(N, N+n_measures):
#         insert_node(&heap, &hnodes[idx])
#     end_t1 = timer()
#     t1 = (end_t1 - start_t1) / n_measures

#     # decrease_key
#     start_t2 = timer()
#     for idx in range(N, N+n_measures):
#         decrease_val(&heap, &hnodes[idx], 0.1 * values[idx])
#     end_t2 = timer()
#     t2 = (end_t2 - start_t2) / n_measures


#     # find min
#     start_t3 = timer()
#     for i in range(n_measures):
#         min = heap.min_node.val
#     end_t3 = timer()
#     t3 = (end_t3 - start_t3) / n_measures    

#     # extract_min
#     start_t4 = timer()
#     for i in range(n_measures):
#         hnode = remove_min(&heap)
#     end_t4 = timer()
#     t4 = (end_t4 - start_t4) / n_measures

#     # free_heap
#     start_t5 = timer()
#     free(hnodes)
#     end_t5 = timer()
#     t5 = end_t5 - start_t5

#     df = pd.DataFrame({"heap_size": N,
#                        "init_heap": t0,
#                        "insert_node": t1,
#                        "decrease_key": t2,
#                        "find_min": t3,
#                        "extract_min": t4,
#                        "free_heap": t5}, index=[0])

#     return df



# cpdef test_is_empty():

#     cdef: 
#         BinaryHeap bheap
#         unsigned int idx

#     init_heap(&bheap, 1)

#     assert bheap.length == 1
#     assert bheap.size == 0
#     assert is_empty(&bheap)
#     min_heap_insert(&bheap, 0, 3.0)
#     assert bheap.length == 1
#     assert bheap.size == 1
#     assert not is_empty(&bheap)
#     idx = extract_min(&bheap)
#     assert bheap.length == 1
#     assert bheap.size == 0
#     assert is_empty(&bheap) 

#     free_heap(&bheap)


# cpdef test_peek():

#     cdef: 
#         BinaryHeap bheap

#     k = 4
#     init_heap(&bheap, k)
#     min_val = 2.0
#     for i in range(k):
#         min_heap_insert(&bheap, i, min_val)
#         assert peek(&bheap) == min_val
#         min_val -= 1.0
#     min_val += 1.0
#     for i in range(k-1):
#         idx = extract_min(&bheap)
#         min_val += 1.0
#         assert peek(&bheap) == min_val

#     free_heap(&bheap)


# # cpdef test_decrease():
    
# #     cdef: 
# #         BinaryHeap bheap


# #     init_heap(&bheap, 4)
# #     min_heap_insert(&bheap, 0, 3.0)
# #     assert bheap.nodes[0].state == IN_HEAP
# #     assert bheap.nodes[1].state == NOT_IN_HEAP
# #     assert bheap.nodes[2].state == NOT_IN_HEAP
# #     assert bheap.nodes[3].state == NOT_IN_HEAP
# #     min_heap_insert(&bheap, 1, 2.0)
# #     assert bheap.nodes[0].state == IN_HEAP
# #     assert bheap.nodes[1].state == IN_HEAP
# #     assert bheap.nodes[2].state == NOT_IN_HEAP
# #     assert bheap.nodes[3].state == NOT_IN_HEAP
# #     min_heap_insert(&bheap, 2, 1.0)
# #     assert bheap.nodes[0].state == IN_HEAP
# #     assert bheap.nodes[1].state == IN_HEAP
# #     assert bheap.nodes[2].state == IN_HEAP
# #     assert bheap.nodes[3].state == NOT_IN_HEAP
# #     assert bheap.length == 4
# #     assert bheap.size == 3
# #     assert peek(&bheap) == 1.0
# #     decrease_key_from_node_index(&bheap, 0, 0.0)
# #     assert peek(&bheap) == 0.0
# #     idx = extract_min(&bheap)
# #     assert idx == 0
# #     assert peek(&bheap) == 1.0
# #     assert bheap.nodes[0].key == 0.0
# #     assert bheap.nodes[0].state == SCANNED
# #     assert bheap.nodes[1].state == IN_HEAP
# #     assert bheap.nodes[2].state == IN_HEAP
# #     assert bheap.nodes[3].state == NOT_IN_HEAP
# #     decrease_key_from_node_index(&bheap, 1,  0.0)
# #     decrease_key_from_node_index(&bheap, 2, -1.0)
# #     assert peek(&bheap) == -1.0
# #     assert bheap.nodes[1].key ==  0.0
# #     assert bheap.nodes[2].key == -1.0
# #     decrease_key_from_node_index(&bheap, 1, -2.0)
# #     assert peek(&bheap) == -2.0
# #     assert bheap.nodes[1].key == -2.0
# #     assert bheap.nodes[2].key == -1.0
# #     idx = extract_min(&bheap)
# #     assert idx == 1
# #     assert peek(&bheap) == -1.0
# #     assert bheap.nodes[0].state == SCANNED
# #     assert bheap.nodes[1].state == SCANNED
# #     assert bheap.nodes[2].state == IN_HEAP
# #     assert bheap.nodes[3].state == NOT_IN_HEAP

# #     free_heap(&bheap)


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


