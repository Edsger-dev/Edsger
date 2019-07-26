
# COMPILER DIRECTIVES
#cython: boundscheck=False, wraparound=False, embedsignature=True
#cython: cdivision=True, initializedcheck=False
# COMPILER DIRECTIVES

from scipy.sparse import csr_matrix

from edsger.priority_queue_binary_heap cimport *

cdef void _sssp_bt(
    int origin,
    int n_vert,
    int tid,
    DTYPE_t[:] graph_costs,
    ITYPE_t[:] csr_indices,
    ITYPE_t[:] csr_indptr,
    ITYPE_t[:, :] from_vert,
    ITYPE_t[:, :] from_edge,
    DTYPE_t[:, :] tt_mat) nogil:
    """ Single source shortest path with backtracking variables.
    """

    cdef:
        int i, head_vert_idx, vert_idx, edge_idx
        double edge_w, tmp_scal

        cdef BinaryHeap bheap
        # FibonacciHeap heap
        # # FibonacciNode *hnode
        # FibonacciNode *head_hnode
        # FibonacciNode *hnodes = <FibonacciNode*> malloc(n_vert * sizeof(FibonacciNode))

    # # init #
    # # ---- #
    # for i in range(n_vert):
    #     initialize_node(&hnodes[i], i)
    #     from_vert[i, tid] = -1
    #     from_edge[i, tid] = -1
    #     tt_mat[i, tid] = 0.0
    # heap.min_node = NULL
    # insert_node(&heap, &hnodes[origin])
    # from_vert[origin, tid] = origin

    # # main loop #
    # # --------- #
    # while heap.min_node:

    #     # remove vertex with min travel time from heap
    #     hnode = remove_min(&heap)
    #     hnode.state = SCANNED
    #     vert_idx = hnode.index
    #     tt_mat[vert_idx, tid] = hnode.val

    #     # loop over outgoing edges
    #     for edge_idx in range(csr_indptr[vert_idx], csr_indptr[vert_idx+1]):

    #         head_vert_idx = csr_indices[edge_idx]
    #         head_hnode = &hnodes[head_vert_idx]

    #         if head_hnode.state != SCANNED:

    #             edge_w = graph_costs[edge_idx]
    #             tmp_scal = hnode.val + edge_w

    #             if head_hnode.state == NOT_IN_HEAP:

    #                 head_hnode.val = tmp_scal
    #                 head_hnode.state = IN_HEAP
    #                 insert_node(&heap, head_hnode)

    #                 from_vert[head_vert_idx, tid] = vert_idx
    #                 from_edge[head_vert_idx, tid] = edge_idx

    #             elif head_hnode.val > tmp_scal:

    #                 decrease_val(&heap, head_hnode, tmp_scal)

    #                 from_vert[head_vert_idx, tid] = vert_idx
    #                 from_edge[head_vert_idx, tid] = edge_idx

    # cleanup
    free_heap(&bheap)