import numpy as np
import pandas as pd

from edsger.shortestpath import (
    convert_sorted_graph_to_csr,
    convert_sorted_graph_to_csc,
)
from edsger.commons import UITYPE_PY, DTYPE_PY


class Path(object):
    def __init__(
        self,
        edges_df,
        source="source",
        target="target",
        weight="weight",
        orientation="one-to-all",
        check_edges=True,
    ):
        # load the edges
        if check_edges:
            self._check_edges(edges_df, source, target, weight)
        self._edges = edges_df[[source, target, weight]]
        self.n_edges = len(self._edges)

        # reindex the vertices
        self._vertices = self._permute_graph(source, target)
        self.n_vertices = len(self._vertices)

        # prepare the data
        if orientation == "one-to-all":
            self._edges.sort_values(by=[source, target], inplace=True)
        else:
            self._edges.sort_values(by=[target, source], inplace=True)

        self._tail_vert = self._edges[source].values.astype(UITYPE_PY)
        self._head_vert = self._edges[target].values.astype(UITYPE_PY)
        self._edge_weights = self._edges[weight].values.astype(DTYPE_PY)

        self._check_orientation(orientation)
        self._orientation = orientation
        if self._orientation == "one-to-all":
            self._indptr = convert_sorted_graph_to_csr(
                self._tail_vert, self._head_vert, self.n_vertices
            )
        else:
            self._indptr = convert_sorted_graph_to_csc(
                self._tail_vert, self._head_vert, self.n_vertices
            )

    def _check_edges(self, edges_df, source, target, weight):

        if type(edges_df) != pd.core.frame.DataFrame:
            raise TypeError("edges_df should be a pandas DataFrame")

        if source not in edges_df:
            raise KeyError(
                f"'{source}' column not found in graph edges dataframe"
            )

        if target not in edges_df:
            raise KeyError(
                f"'{target}' column not found in graph edges dataframe"
            )

        if weight not in edges_df:
            raise KeyError(
                f"'{weight}' column not found in graph edges dataframe"
            )

        if edges_df[[source, target, weight]].isna().any().any():
            raise ValueError(
                " ".join(
                    [
                        f"edges_df[[{source}, {target}, {weight}]] ",
                        "should not have missing values",
                    ]
                )
            )

        for col in [source, target]:
            if not pd.api.types.is_integer_dtype(edges_df[col].dtype):
                raise TypeError(f"edges_df[{col}] should be of integer type")

        if not pd.api.types.is_numeric_dtype(edges_df[weight].dtype):
            raise TypeError(f"edges_df[{weight}] should be of numeric type")

        if edges_df[weight].min() < 0.0:
            raise ValueError(f"edges_df[{weight}] should not be negative")

        if not np.isfinite(edges_df[weight]).all():
            raise ValueError(f"edges_df[{weight}] should be finite")

        # the graph must be a Simple directed graphs
        if edges_df.duplicated(subset=[source, target]).any():
            raise ValueError("there should be no parallel edges in the graph")
        if (edges_df[source] == edges_df[target]).any():
            raise ValueError("there should be no loop in the graph")

    def _permute_graph(self, source, target):
        """ Create a vertex table and reindex the vertices.
        """

        vertices = pd.DataFrame(
            data={
                "vert_idx": np.union1d(
                    self._edges[source].values, self._edges[target].values
                )
            }
        )
        vertices["vert_idx_new"] = vertices.index
        vertices.index.name = "index"

        self._edges = pd.merge(
            self._edges,
            vertices[["vert_idx", "vert_idx_new"]],
            left_on=source,
            right_on="vert_idx",
            how="left",
        )
        self._edges.drop([source, "vert_idx"], axis=1, inplace=True)
        self._edges.rename(columns={"vert_idx_new": source}, inplace=True)

        self._edges = pd.merge(
            self._edges,
            vertices[["vert_idx", "vert_idx_new"]],
            left_on=target,
            right_on="vert_idx",
            how="left",
        )
        self._edges.drop([target, "vert_idx"], axis=1, inplace=True)
        self._edges.rename(columns={"vert_idx_new": target}, inplace=True)

        vertices.rename(columns={"vert_idx": "vert_idx_old"}, inplace=True)
        vertices.reset_index(drop=True, inplace=True)
        vertices.sort_values(by="vert_idx_new", inplace=True)

        vertices.index.name = "index"
        self._edges.index.name = "index"

        return vertices

    def _check_orientation(self, orientation):
        if orientation not in ["one-to-all", "all-to-one"]:
            raise ValueError(
                f"orientation should be either 'one-to-all' or 'all-to-one'"
            )

    def run(self, vertex):

        if vertex not in self._vertices.vert_idx_old.values:
            raise ValueError(f"vertex {vertex} not found in graph")
        vertex_new = self._vertices.loc[
            self._vertices.vert_idx_old == vertex, "vert_idx_new"
        ]

        if self._orientation == "one-to-all":
            path_lengths = path_length(
                self._head_vert,
                self._indptr,
                self._edge_weights,
                vertex_new,
                self.n_vertices,
                n_jobs=-1,
            )

        self._vertices["length"] = path_lengths

        return self._vertices[["vert_idx_old", "length"]].sort_values(
            by="vert_idx_old"
        )
