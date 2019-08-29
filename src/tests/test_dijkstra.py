import numpy as np
import pandas as pd
import pytest

from edsger.dijkstra import Path


@pytest.fixture
def braess():
    """ Braess-like graph
    """
    edges_df = pd.DataFrame(
        data={
            "source": [0, 0, 1, 1, 2],
            "target": [1, 2, 2, 3, 3],
            "weight": [1.0, 2.0, 0.0, 2.0, 1.0],
        }
    )
    return edges_df


def test_load_edges(braess):

    edges_df = braess

    with pytest.raises(TypeError, match=r"should be a pandas DataFrame"):
        Path("aaa")
    with pytest.raises(KeyError, match=r"not found in graph edges dataframe"):
        Path(edges_df, source="tail")
    with pytest.raises(KeyError, match=r"not found in graph edges dataframe"):
        Path(edges_df, target="head")
    with pytest.raises(KeyError, match=r"not found in graph edges dataframe"):
        Path(edges_df, weight="cost")
    with pytest.raises(ValueError, match=r"should not have missing values"):
        Path(edges_df.replace(0, np.nan))
    with pytest.raises(TypeError, match=r"should be of integer type"):
        Path(edges_df.astype({"source": float}))
    with pytest.raises(TypeError, match=r"should be of integer type"):
        Path(edges_df.astype({"target": float}))
    with pytest.raises(TypeError, match=r"should be of numeric type"):
        Path(edges_df.astype({"weight": str}))
    with pytest.raises(ValueError, match=r"should not be negative"):
        Path(pd.concat([edges_df[["source", "target"]], edges_df.weight * -1], axis=1))
