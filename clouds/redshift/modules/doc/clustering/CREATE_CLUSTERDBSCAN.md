## CREATE_CLUSTERDBSCAN

```sql:signature
CREATE_CLUSTERDBSCAN(input, output_table, geom_column, epsilon, min_points [, partition_column])
```

**Description**

Takes a set of points as input and groups them into clusters using the DBSCAN algorithm, writing the result to a new table.

DBSCAN groups together points lying in dense neighborhoods and labels the rest as noise. Unlike k-means it does not require the number of clusters up front, it finds clusters of arbitrary shape, and it does not force every point into a cluster.

**Input parameters**

* `input`: `VARCHAR` name of the table or literal SQL query to be clustered.
* `output_table`: `VARCHAR(MAX)` qualified name of the output table, e.g. `<my-schema>.<my-output-table>`. It is replaced if it already exists.
* `geom_column`: `VARCHAR` name of the `POINT` column to be clustered, in SRID 4326 or 0.
* `epsilon`: `FLOAT8` the search radius in meters.
* `min_points`: `INT` the minimum number of points, counting the point itself, that form a dense neighborhood.
* `partition_column` (optional): `VARCHAR` name of a column to cluster within, `NULL` values forming their own group. If omitted the whole input is one set.

**Output**

The output table contains all the columns of `input` plus `cluster_id` and `pt_type`.

`cluster_id` is a zero-based cluster index, restarting at zero in each partition. It is `NULL` for any point that is not in a cluster.

`pt_type` is the role of the point. A **core** point has at least `min_points` points within `epsilon` of it, counting itself, and core points within `epsilon` of each other belong to the same cluster. A **border** point is not a core point but lies within `epsilon` of one, so it joins that cluster without connecting it to any other. A **noise** point is neither. A **skipped** point was never clustered because its geometry was `NULL`, which is absent input rather than a result.

````hint:info
**info**

Cluster assignments match `sklearn.cluster.DBSCAN` with `metric='haversine'` for the same `epsilon` and `min_points`. Where DBSCAN is inherently ambiguous — a border point reachable from two clusters — this implementation always picks the cluster with the lowest canonical label, so results are deterministic and reproducible across runs.

````

````hint:warning
**warning**

Only `POINT` geometries are supported. The input must not already have columns named `cluster_id`, `pt_type` or `__carto_idx`, so the output of one call cannot be fed straight back into another.

Runtime is driven by point *density* rather than row count: the cost grows with the number of points within `epsilon` of each other, so a large radius over a tightly packed area is the expensive case.

````

**Examples**

```sql
CALL carto.CREATE_CLUSTERDBSCAN('<my-schema>.<my-table>', '<my-schema>.<my-output-table>', 'geom', 100, 5);
-- The table `<my-schema>.<my-output-table>` will be created adding the columns
-- cluster_id and pt_type to those in `<my-schema>.<my-table>`.
```

```sql
CALL carto.CREATE_CLUSTERDBSCAN('SELECT * FROM <my-schema>.<my-table>', '<my-schema>.<my-output-table>', 'geom', 100, 5);
-- The table `<my-schema>.<my-output-table>` will be created adding the columns
-- cluster_id and pt_type to those returned in the input query.
```

```sql
CALL carto.CREATE_CLUSTERDBSCAN('<my-schema>.<my-table>', '<my-schema>.<my-output-table>', 'geom', 25, 3, 'store_id');
-- Points are clustered independently for each store_id, in a single call.
```

```sql
-- Keep only the clustered points and count them per cluster
SELECT cluster_id, COUNT(*) AS points
FROM <my-schema>.<my-output-table>
WHERE cluster_id IS NOT NULL
GROUP BY cluster_id
ORDER BY points DESC;
```
