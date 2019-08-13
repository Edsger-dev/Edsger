
# COMPILER DIRECTIVES
#cython: boundscheck=False, wraparound=False, embedsignature=True
#cython: cdivision=True, initializedcheck=False
# COMPILER DIRECTIVES

cimport numpy as np
import numpy as np
from scipy.sparse import csr_matrix

from edsger.priority_queue_binary_heap cimport *
from edsger.commons cimport DTYPE, DTYPE_t, UITYPE, UITYPE_t, SCANNED, NOT_IN_HEAP


cpdef convert_sorted_graph_to_csr(
    tail_nodes,
    head_nodes,
    n_vertices):
    """ Compute the CSR representation of the node-node adjacency matrix of the 
    graph.

    input
    =====

    output
    ======

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


cpdef sssp_basic(
    UITYPE_t[:] csr_indices,
    UITYPE_t[:] csr_indptr,
    DTYPE_t[:] edge_weights,
    unsigned int origin_vert,
    unsigned int n_vertices):

    cdef:
        UITYPE_t i
        UITYPE_t tail_vert_idx, edge_idx, head_vert_idx
        DTYPE_t edge_weight, tail_vert_val, tmp_scal
        BinaryHeap bheap
        int vert_state
    travel_time = np.zeros(n_vertices, dtype=DTYPE)

    init_heap(&bheap, n_vertices)
    min_heap_insert(&bheap, origin_vert, 0.)

    while bheap.size > 0:
        tail_vert_idx = extract_min(&bheap)
        tail_vert_val = bheap.nodes[tail_vert_idx].key

        for edge_idx in range(csr_indptr[tail_vert_idx], csr_indptr[tail_vert_idx + 1]):
            head_vert_idx = csr_indices[edge_idx]
            vert_state = bheap.nodes[head_vert_idx].state
            head_vert_val = bheap.nodes[head_vert_idx].key

            if vert_state != SCANNED:
                edge_weight = edge_weights[edge_idx]
                tmp_scal = tail_vert_val + edge_weight

                if vert_state == NOT_IN_HEAP:
                    min_heap_insert(&bheap, head_vert_idx, tmp_scal)

                elif head_vert_val > tmp_scal:
                    decrease_key_from_node_index(&bheap, head_vert_idx, tmp_scal)

    # TODO : function to get all keys
    for i in range(n_vertices):
        travel_time[i] = bheap.nodes[i].key

    free_heap(&bheap)

    return travel_time