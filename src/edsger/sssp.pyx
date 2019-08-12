
# COMPILER DIRECTIVES
#cython: boundscheck=False, wraparound=False, embedsignature=True
#cython: cdivision=True, initializedcheck=False
# COMPILER DIRECTIVES

cimport numpy as np
import numpy as np
from scipy.sparse import csr_matrix

from edsger.priority_queue_binary_heap cimport *
from edsger.commons cimport UITYPE


cpdef convert_sorted_graph_to_csr(
    tail_nodes,
    head_nodes,
    n_vertices):
    """ Compute the CSR representation of the node-node adjacency matrix of the 
    graph.

    input
    =====
    * BinaryHeap* bheap : binary heap

    assumption
    ==========
    * edges are sorted by tail vertices first and head vertices second
    """

    edge_count = head_nodes.shape[0]
    data = np.ones(edge_count, dtype=UITYPE)
    csr_mat = csr_matrix(
        (data, (tail_nodes, head_nodes)),
        shape=(n_vertices, n_vertices),
        dtype=UITYPE)

    return csr_mat.indptr.astype(UITYPE)


# cdef void _sssp_bt(
#     # int origin,
#     # int n_vert,   
#     # int tid,
#     # DTYPE_t[:] graph_costs,
#     # ITYPE_t[:] csr_indices,
#     # ITYPE_t[:] csr_indptr,
#     # ITYPE_t[:, :] from_vert,
#     # ITYPE_t[:, :] from_edge,
#     # DTYPE_t[:, :] tt_mat
#     ) nogil:
#     """ Single source shortest path with backtracking variables.
#     """

#     cdef:
#         int i, head_vert_idx, vert_idx, edge_idx
#         double edge_w, tmp_scal

#         cdef BinaryHeap bheap
#         # FibonacciHeap heap
#         # # FibonacciNode *hnode
#         # FibonacciNode *head_hnode
#         # FibonacciNode *hnodes = <FibonacciNode*> malloc(n_vert * sizeof(FibonacciNode))

#     # # init #
#     # # ---- #
#     # for i in range(n_vert):
#     #     initialize_node(&hnodes[i], i)
#     #     from_vert[i, tid] = -1
#     #     from_edge[i, tid] = -1
#     #     tt_mat[i, tid] = 0.0
#     # heap.min_node = NULL
#     # insert_node(&heap, &hnodes[origin])
#     # from_vert[origin, tid] = origin

#     # # main loop #
#     # # --------- #
#     # while heap.min_node:

#     #     # remove vertex with min travel time from heap
#     #     hnode = remove_min(&heap)
#     #     hnode.state = SCANNED
#     #     vert_idx = hnode.index
#     #     tt_mat[vert_idx, tid] = hnode.val

#     #     # loop over outgoing edges
#     #     for edge_idx in range(csr_indptr[vert_idx], csr_indptr[vert_idx+1]):

#     #         head_vert_idx = csr_indices[edge_idx]
#     #         head_hnode = &hnodes[head_vert_idx]

#     #         if head_hnode.state != SCANNED:

#     #             edge_w = graph_costs[edge_idx]
#     #             tmp_scal = hnode.val + edge_w

#     #             if head_hnode.state == NOT_IN_HEAP:

#     #                 head_hnode.val = tmp_scal
#     #                 head_hnode.state = IN_HEAP
#     #                 insert_node(&heap, head_hnode)

#     #                 from_vert[head_vert_idx, tid] = vert_idx
#     #                 from_edge[head_vert_idx, tid] = edge_idx

#     #             elif head_hnode.val > tmp_scal:

#     #                 decrease_val(&heap, head_hnode, tmp_scal)

#     #                 from_vert[head_vert_idx, tid] = vert_idx
#     #                 from_edge[head_vert_idx, tid] = edge_idx

#     # cleanup
#     free_heap(&bheap)