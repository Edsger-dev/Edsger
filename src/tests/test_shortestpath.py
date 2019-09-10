import numpy as np
import pandas as pd
import pytest

from edsger.shortestpath import convert_sorted_graph_to_csr, path_length_from
from edsger.commons import INFINITY_PY, UITYPE_PY


@pytest.fixture
def one_edge_01():
    """ network with 2 vertices, 1 edge

        0 ----0---> 1
    """
    graph_edges = pd.DataFrame(
        {"tail_vert": [0], "head_vert": [1], "t0": [1.0]}
    )

    return graph_edges


@pytest.fixture
def braess_network_01():
    """ Braess-like network in CSR format.
    """

    csr_indices = np.array([1, 2, 2, 3, 3], dtype=UITYPE_PY)
    csr_indptr = np.array([0, 2, 4, 5, 5], dtype=UITYPE_PY)
    edge_weights = np.array([1.0, 2.0, 0.0, 2.0, 1.0], dtype=np.float)
    return csr_indices, csr_indptr, edge_weights


def test_convert_01(one_edge_01):
    """ Test of the conversion from a sorted graph (tail node index first,
    head node index second) to a CSR format.

    The sorted graph is the following one (single-edge network):
    edge index: 0
    tail nodes: 0
    head nodes: 1
    """

    # data loading
    graph_edges = one_edge_01
    tail_nodes = graph_edges.tail_vert.values
    head_nodes = graph_edges.head_vert.values

    # conversion
    indptr_ref = np.array([0, 1, 1], dtype=UITYPE_PY)
    indptr = convert_sorted_graph_to_csr(tail_nodes, head_nodes, 2)
    assert isinstance(indptr, np.ndarray)
    np.testing.assert_array_equal(indptr_ref, indptr)
    assert np.issubdtype(indptr.dtype, np.integer)


def test_convert_02():
    """ Test of the conversion from a sorted graph (tail node index first,
    head node index second) to a CSR format.

    The sorted graph is the following one (Braess-like network):
    edge index: 0, 1, 2, 3, 4
    tail nodes: 0, 0, 1, 1, 2
    head nodes: 1, 2, 2, 3, 3
    """

    # data creation
    tail_nodes = np.array([0, 0, 1, 1, 2])
    head_nodes = np.array([1, 2, 2, 3, 3])

    # conversion
    indptr_ref = np.array([0, 2, 4, 5, 5], dtype=UITYPE_PY)
    indptr = convert_sorted_graph_to_csr(tail_nodes, head_nodes, 4)
    assert isinstance(indptr, np.ndarray)
    np.testing.assert_array_equal(indptr_ref, indptr)
    assert np.issubdtype(indptr.dtype, np.integer)


def test_shortestpath_01(one_edge_01):
    """ Test of the basic single-source shortest path algorithm on a one-edge 
    network.
    """

    # data loading
    graph_edges = one_edge_01

    # data preparation
    tail_nodes = graph_edges.tail_vert.values.astype(UITYPE_PY)
    head_nodes = graph_edges.head_vert.values.astype(UITYPE_PY)
    edge_weights = graph_edges.t0.values.astype(np.float64)
    csr_indptr = convert_sorted_graph_to_csr(tail_nodes, head_nodes, 2)
    csr_indices = np.copy(head_nodes)

    # origin: node 0
    travel_time_ref = np.array([0.0, 1.0], dtype=np.float)
    travel_time = path_length_from(csr_indices, csr_indptr, edge_weights, 0, 2)
    assert isinstance(travel_time, np.ndarray)
    np.testing.assert_array_equal(travel_time_ref, travel_time)
    assert np.issubdtype(travel_time.dtype, np.floating)

    # origin: node 1
    travel_time_ref = np.array([INFINITY_PY, 0.0], dtype=np.float)
    travel_time = path_length_from(csr_indices, csr_indptr, edge_weights, 1, 2)
    assert isinstance(travel_time, np.ndarray)
    np.testing.assert_array_equal(travel_time_ref, travel_time)
    assert np.issubdtype(travel_time.dtype, np.floating)


def test_shortestpath_02(braess_network_01):
    """ Test of the basic single-source shortest path algorithm on a Braess-like
     network.
    """

    # data loading
    csr_indices, csr_indptr, edge_weights = braess_network_01

    # origin: node 0
    travel_time_ref = np.array([0.0, 1.0, 1.0, 2.0], dtype=np.float)
    travel_time = path_length_from(csr_indices, csr_indptr, edge_weights, 0, 4)
    assert isinstance(travel_time, np.ndarray)
    np.testing.assert_array_equal(travel_time_ref, travel_time)
    assert np.issubdtype(travel_time.dtype, np.floating)

    # origin: node 1
    travel_time_ref = np.array([INFINITY_PY, 0.0, 0.0, 1.0], dtype=np.float)
    travel_time = path_length_from(csr_indices, csr_indptr, edge_weights, 1, 4)
    assert isinstance(travel_time, np.ndarray)
    np.testing.assert_array_equal(travel_time_ref, travel_time)
    assert np.issubdtype(travel_time.dtype, np.floating)

    # origin: node 2
    travel_time_ref = np.array(
        [INFINITY_PY, INFINITY_PY, 0.0, 1.0], dtype=np.float
    )
    travel_time = path_length_from(csr_indices, csr_indptr, edge_weights, 2, 4)
    assert isinstance(travel_time, np.ndarray)
    np.testing.assert_array_equal(travel_time_ref, travel_time)
    assert np.issubdtype(travel_time.dtype, np.floating)

    # origin: node 3
    travel_time_ref = np.array(
        [INFINITY_PY, INFINITY_PY, INFINITY_PY, 0.0], dtype=np.float
    )
    travel_time = path_length_from(csr_indices, csr_indptr, edge_weights, 3, 4)
    assert isinstance(travel_time, np.ndarray)
    np.testing.assert_array_equal(travel_time_ref, travel_time)
    assert np.issubdtype(travel_time.dtype, np.floating)
