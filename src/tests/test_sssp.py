
import numpy as np

from edsger.sssp import convert_sorted_graph_to_csr

def test_convert_01():
    """ Braess' network
    """
    tail_nodes = np.array([0, 0, 1, 1, 2])
    head_nodes = np.array([1, 2, 2, 3, 3])

    indptr_ref = np.array([0, 2, 4, 5, 5], dtype=np.uint32)
    indptr = convert_sorted_graph_to_csr(tail_nodes, head_nodes, 4)

    assert  isinstance(indptr_ref, np.ndarray)
    np.testing.assert_array_equal(indptr, indptr_ref)
    assert np.issubdtype(indptr.dtype, np.integer)
