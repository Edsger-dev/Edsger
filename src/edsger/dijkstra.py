import pandas as pd

from edsger.shortestpath import convert_sorted_graph_to_csr, path_length


class Path(object):
    def __init__(self, edges_df, source="source", target="target", weight="weight"):
        self._edges = None
        self._load_edges(edges_df, source, target, weight)

    def _load_edges(self, edges_df, source, target, weight):

        if type(edges_df) != pd.core.frame.DataFrame:
            raise TypeError("edges_df should be a pandas DataFrame")

        if source not in edges_df:
            raise KeyError(f"'{source}' column not found in graph edges dataframe")

        if target not in edges_df:
            raise KeyError(f"'{target}' column not found in graph edges dataframe")

        if weight not in edges_df:
            raise KeyError(f"'{weight}' column not found in graph edges dataframe")

        if edges_df[[source, target, weight]].isna().any().any():
            raise ValueError(
                f"edges_df[[{source}, {target}, {weight}]] should not have missing values"
            )

        for col in [source, target]:
            if not pd.api.types.is_integer_dtype(edges_df[col].dtype):
                raise TypeError(f"edges_df[{col}] should be of integer type")

        if not pd.api.types.is_numeric_dtype(edges_df[weight].dtype):
            raise TypeError(f"edges_df[{weight}] should be of numeric type")

        if edges_df[weight].min() < 0.0:
            raise ValueError(f"edges_df[{weight}] should not be negative")

        self._edges = edges_df[[source, target, weight]].copy(deep=True)
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
