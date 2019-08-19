
# COMPILER DIRECTIVES
#cython: boundscheck=False, wraparound=False, embedsignature=True
#cython: cdivision=True, initializedcheck=False
# COMPILER DIRECTIVES

cimport numpy as np
import numpy as np
from scipy.sparse import csr_matrix
from cython.parallel import prange

from edsger.priority_queue_binary_heap cimport *
from edsger.commons cimport DTYPE, DTYPE_t, UITYPE, UITYPE_t, SCANNED, NOT_IN_HEAP, N_THREADS


cpdef convert_sorted_graph_to_csr(
    tail_nodes,
    head_nodes,
    n_vertices):
    """ Compute the CSR representation of the node-node adjacency matrix of the 
    graph.

    assumption
    ==========
    * edges are sorted by tail vertices first and head vertices second and 
      and edges have been reindexed
    """

    edge_count = head_nodes.shape[0]
    data = np.ones(edge_count, dtype=UITYPE)
    csr_mat = csr_matrix(
        (data, (tail_nodes, head_nodes)),
        shape=(n_vertices, n_vertices),
        dtype=UITYPE)

    return csr_mat.indptr.astype(UITYPE)


cpdef np.ndarray path_length(
    UITYPE_t[:] csr_indices,
    UITYPE_t[:] csr_indptr,
    DTYPE_t[:] edge_weights,
    unsigned int origin_vert,
    unsigned int n_vertices,
    int n_jobs=1):
    """ Compute single-source shortest path (from one vertex to all vertices).
    """

    cdef:
        UITYPE_t tail_vert_idx, head_vert_idx, edge_idx  # vertex and edge indices
        DTYPE_t tail_vert_val, head_vert_val  # vertex travel times
        BinaryHeap bheap  # binary heap
        int vert_state  # vertex state

    # initialization (the priority queue is filled with all nodes)
    # all nodes of INFINITY key
    init_heap(&bheap, n_vertices)

    # the key is set to zero for the origin vertex
    min_heap_insert(&bheap, origin_vert, 0.)

    # main loop
    while bheap.size > 0:
        tail_vert_idx = extract_min(&bheap)
        tail_vert_val = bheap.nodes[tail_vert_idx].key
        # loop on outgoing edges
        for edge_idx in range(csr_indptr[tail_vert_idx], csr_indptr[tail_vert_idx + 1]):
            head_vert_idx = csr_indices[edge_idx]
            vert_state = bheap.nodes[head_vert_idx].state
            if vert_state != SCANNED:
                head_vert_val = tail_vert_val + edge_weights[edge_idx]
                if vert_state == NOT_IN_HEAP:
                    min_heap_insert(&bheap, head_vert_idx, head_vert_val)
                elif bheap.nodes[head_vert_idx].key > head_vert_val:
                    decrease_key_from_node_index(&bheap, head_vert_idx, head_vert_val)

    # copy the results into a numpy array
    path_lengths = np.zeros(n_vertices, dtype=DTYPE)
    cdef:
        UITYPE_t i  # loop counter
        DTYPE_t[:] path_lengths_view = path_lengths
        int num_threads = n_jobs
    if num_threads < 1:
        num_threads = N_THREADS
    for i in prange(
        n_vertices, 
        schedule=guided, 
        nogil=True, 
        num_threads=num_threads):
        path_lengths_view[i] = bheap.nodes[i].key

    free_heap(&bheap)  # cleanup

    return path_lengths


cpdef np.ndarray path_length_tmp(
    UITYPE_t[:] csr_indices,
    UITYPE_t[:] csr_indptr,
    DTYPE_t[:] edge_weights,
    unsigned int origin_vert,
    unsigned int n_vertices,
    int n_jobs=1):
    """ Compute single-source shortest path (from one vertex to all vertices).
    """

    cdef:
        UITYPE_t tail_vert_idx, head_vert_idx, edge_idx  # vertex and edge indices
        DTYPE_t tail_vert_val, head_vert_val  # vertex travel times
        BinaryHeap bheap  # binary heap
        int vert_state  # vertex state

    # initialization (the priority queue is filled with all nodes)
    # all nodes of INFINITY key
    init_heap(&bheap, n_vertices)

    # the key is set to zero for the origin vertex
    min_heap_insert(&bheap, origin_vert, 0.)

    # main loop
    while bheap.size > 0:
        tail_vert_idx = extract_min(&bheap)
        tail_vert_val = bheap.nodes[tail_vert_idx].key
        # loop on outgoing edges
        for edge_idx in range(csr_indptr[tail_vert_idx], csr_indptr[tail_vert_idx + 1]):
            head_vert_idx = csr_indices[edge_idx]
            vert_state = bheap.nodes[head_vert_idx].state
            if vert_state != SCANNED:
                head_vert_val = tail_vert_val + edge_weights[edge_idx]
                if vert_state == NOT_IN_HEAP:
                    min_heap_insert(&bheap, head_vert_idx, head_vert_val)
                elif bheap.nodes[head_vert_idx].key > head_vert_val:
                    decrease_key_from_node_index(&bheap, head_vert_idx, head_vert_val)

    # copy the results into a numpy array
    path_lengths = np.zeros(n_vertices, dtype=DTYPE)
    cdef:
        UITYPE_t i  # loop counter
        DTYPE_t[:] path_lengths_view = path_lengths
        int num_threads = n_jobs
    if num_threads < 1:
        num_threads = N_THREADS
    for i in prange(
        n_vertices, 
        schedule=guided, 
        nogil=True, 
        num_threads=num_threads):
        path_lengths_view[i] = bheap.nodes[i].key

    free_heap(&bheap)  # cleanup

    return path_lengths