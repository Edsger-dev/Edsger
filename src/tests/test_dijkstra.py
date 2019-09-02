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
    with pytest.raises(ValueError, match=r"should be finite"):
        Path(
            pd.concat(
                [edges_df[["source", "target"]], edges_df.weight.replace(1.0, np.inf)],
                axis=1,
            )
        )
    with pytest.raises(ValueError, match=r"no parallel edges in the graph"):
        Path(pd.concat([edges_df, edges_df.iloc[-2:-1]], axis=0, ignore_index=True))
    with pytest.raises(ValueError, match=r"no loop in the graph"):
        Path(
            edges_df.append(
                {"source": 3, "target": 3, "weight": 1.0}, ignore_index=True
            ).astype({"source": int, "target": int})
        )


def test_permute_graph():

    edges_df = pd.DataFrame(
        data={
            "source": [5, 5, 10, 10, 20],
            "target": [10, 20, 20, 30, 30],
            "weight": [1.0, 2.0, 0.0, 2.0, 1.0],
        }
    )
    path = Path(edges_df)
    # vert_idx_old  vert_idx_new
    # index
    # 0                 5             0
    # 1                10             1
    # 2                20             2
    # 3                30             3
    #    weight  source  target
    # 0     1.0       0       1
    # 1     2.0       0       2
    # 2     0.0       1       2
    # 3     2.0       1       3
    # 4     1.0       2       3

    print(path._vertices)
    print(path._edges)
    assert True
