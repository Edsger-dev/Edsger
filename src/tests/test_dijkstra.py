import pandas as pd
from edsger.dijkstra import Path


def test_path_01():
    """ Braess-like network
	"""
    edges = pd.DataFrame(
        data={
            "source": [0, 0, 1, 1, 2],
            "target": [1, 2, 2, 3, 3],
            "weight": [1.0, 2.0, 0.0, 2.0, 1.0],
        }
    )
    path = Path(edges)
    assert True
