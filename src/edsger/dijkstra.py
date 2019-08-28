import pandas as pd

from edsger.shortestpath import convert_sorted_graph_to_csr, path_length


class Path(object):
    def __init__(self, edge_df, source="source", target="target", weight="weight"):
        self._edges = None
        self._load_edges(edge_df, source, target, weight)

    def _load_edges(self, edge_df, source, target, weight):

        if type(edge_df) != pd.core.frame.DataFrame:
            raise TypeError("graph_edges should be a pandas DataFrame")

        if source not in edge_df:
            raise KeyError(
                "'source' vertex index column not found in graph edges dataframe"
            )

        if target not in edge_df:
            raise KeyError(
                "'target' vertex index column not found in graph edges dataframe"
            )

        if weight not in edge_df:
            raise KeyError(
                "edge attribute 't0' column not found in graph edges dataframe"
            )

        self._edges = edge_df[[source, target, weight]].copy(deep=True)

        for col in [source, target]:
            if not pd.api.types.is_integer_dtype(self._edges[col].dtype):
                raise TypeError(
                    f"The column named '{col}' of the graph edges dataframe should be of integer type"
                )

        if self._edges[weight].min() < 0.0:
            raise ValueError(
                f"edge attribute '{weight}' should be non-negative numbers"
            )

        # if np.amax(self._edges['t0'].values) == np.inf:
        #     raise ValueError("edge attribute 't0' should not be infinite")

        # if np.amin(self._edges['capacity'].values) < 0.0:
        #     raise ValueError("edge attribute 'capacity' should be non-negative numbers")

        # if np.amax(self._edges['capacity'].values) == np.inf:
        #     raise ValueError("edge attribute 'capacity' should not be infinite")

        # # the graph must be a Simple directed graphs
        # if len(self._edges.drop_duplicates(subset=['tail', 'head'])) < len(self._edges):
        #     raise ValueError("there should be no parallel edges in the graph")
        # if len(self._edges[self._edges["tail"] == self._edges["head"]]) > 0:
        #     raise ValueError("there should be no loop in the graph")

        # if self._connectors:
        #     if self._edges['connector'].dtype != bool:
        #         raise TypeError("The column named '{}' of the graph edges dataframe should be of bool type".format('connector'))
