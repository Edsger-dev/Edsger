import numpy as np
import pandas as pd
import pytest

from edsger.sssp import convert_sorted_graph_to_csr, sssp_basic
from edsger.commons import INFINITY_PY


@pytest.fixture
def one_edge_01():
    """ network with 2 vertices, 1 edge

        0 ----0---> 1
    """
    graph_edges = pd.DataFrame({"tail_vert": [0], "head_vert": [1], "t0": [1.0]})

    return graph_edges


@pytest.fixture
def braess_network_01():
    csr_indices = np.array([1, 2, 2, 3, 3], dtype=np.uint32)
    csr_indptr = np.array([0, 2, 4, 5, 5], dtype=np.uint32)
    edge_weights = np.array([1.0, 2.0, 0.0, 2.0, 1.0], dtype=np.float)
    return csr_indices, csr_indptr, edge_weights


def test_convert_01(one_edge_01):

    graph_edges = one_edge_01

    tail_nodes = graph_edges.tail_vert.values
    head_nodes = graph_edges.head_vert.values

    indptr_ref = np.array([0, 1, 1], dtype=np.uint32)
    indptr = convert_sorted_graph_to_csr(tail_nodes, head_nodes, 2)

    assert isinstance(indptr, np.ndarray)
    np.testing.assert_array_equal(indptr_ref, indptr)
    assert np.issubdtype(indptr.dtype, np.integer)


def test_convert_02():
    tail_nodes = np.array([0, 0, 1, 1, 2])
    head_nodes = np.array([1, 2, 2, 3, 3])

    indptr_ref = np.array([0, 2, 4, 5, 5], dtype=np.uint32)
    indptr = convert_sorted_graph_to_csr(tail_nodes, head_nodes, 4)

    assert isinstance(indptr, np.ndarray)
    np.testing.assert_array_equal(indptr_ref, indptr)
    assert np.issubdtype(indptr.dtype, np.integer)


def test_sssp_01(one_edge_01):

    graph_edges = one_edge_01
    tail_nodes = graph_edges.tail_vert.values.astype(np.uint32)
    head_nodes = graph_edges.head_vert.values.astype(np.uint32)
    edge_weights = graph_edges.t0.values.astype(np.float64)

    csr_indptr = convert_sorted_graph_to_csr(tail_nodes, head_nodes, 2)
    csr_indices = np.copy(head_nodes)
    travel_time_ref = np.array([0.0, 1.0], dtype=np.float)
    travel_time = sssp_basic(csr_indices, csr_indptr, edge_weights, 0, 2)

    assert isinstance(travel_time, np.ndarray)
    np.testing.assert_array_equal(travel_time_ref, travel_time)
    assert np.issubdtype(travel_time.dtype, np.floating)

    travel_time_ref = np.array([INFINITY_PY, 0.0], dtype=np.float)
    travel_time = sssp_basic(csr_indices, csr_indptr, edge_weights, 1, 2)

    assert isinstance(travel_time, np.ndarray)
    np.testing.assert_array_equal(travel_time_ref, travel_time)
    assert np.issubdtype(travel_time.dtype, np.floating)


def test_sssp_02(braess_network_01):
    csr_indices, csr_indptr, edge_weights = braess_network_01

    travel_time_ref = np.array([0.0, 1.0, 1.0, 2.0], dtype=np.float)
    travel_time = sssp_basic(csr_indices, csr_indptr, edge_weights, 0, 4)
    assert isinstance(travel_time, np.ndarray)
    np.testing.assert_array_equal(travel_time_ref, travel_time)
    assert np.issubdtype(travel_time.dtype, np.floating)

    travel_time_ref = np.array([INFINITY_PY, 0.0, 0.0, 1.0], dtype=np.float)
    travel_time = sssp_basic(csr_indices, csr_indptr, edge_weights, 1, 4)
    assert isinstance(travel_time, np.ndarray)
    np.testing.assert_array_equal(travel_time_ref, travel_time)
    assert np.issubdtype(travel_time.dtype, np.floating)

    travel_time_ref = np.array([INFINITY_PY, INFINITY_PY, 0.0, 1.0], dtype=np.float)
    travel_time = sssp_basic(csr_indices, csr_indptr, edge_weights, 2, 4)
    assert isinstance(travel_time, np.ndarray)
    np.testing.assert_array_equal(travel_time_ref, travel_time)
    assert np.issubdtype(travel_time.dtype, np.floating)

    travel_time_ref = np.array(
        [INFINITY_PY, INFINITY_PY, INFINITY_PY, 0.0], dtype=np.float
    )
    travel_time = sssp_basic(csr_indices, csr_indptr, edge_weights, 3, 4)
    assert isinstance(travel_time, np.ndarray)
    np.testing.assert_array_equal(travel_time_ref, travel_time)
    assert np.issubdtype(travel_time.dtype, np.floating)
