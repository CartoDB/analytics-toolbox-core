## CREATE_CLUSTERDBSCAN

```sql:signature
CREATE_CLUSTERDBSCAN(input, output_table, geom_column, epsilon, min_points)
CREATE_CLUSTERDBSCAN(input, output_table, geom_column, epsilon, min_points, partition_column)
```

**Description**

Takes a set of points as input and groups them into clusters using the DBSCAN algorithm. Creates a new table with the same columns as `input` plus a `cluster_id` column holding the cluster index of each point, and a `pt_type` column describing its role in the cluster.

DBSCAN groups together points that lie in dense neighbourhoods and labels the rest as noise. Unlike k-means it does not require the number of clusters up front, it finds clusters of arbitrary shape, and it does not force every point into a cluster.

A point is a **core** point when at least `min_points` points (counting itself) lie within `epsilon` of it. Core points that are within `epsilon` of each other belong to the same cluster. A **border** point is not a core point but lies within `epsilon` of one; it joins that cluster but does not connect it to any other. Everything else is **noise** and gets a `NULL` cluster id.

**Input parameters**

* `input`: `VARCHAR` name of the table or literal SQL query to be clustered.
* `output_table`: `VARCHAR(MAX)` qualified name of the output table, e.g. `<my-schema>.<my-output-table>`. It is replaced if it already exists.
* `geom_column`: `VARCHAR` name of the point column to be clustered. It must contain `POINT` geometries in SRID 4326 (or 0), since distances are measured with `ST_DistanceSphere`.
* `epsilon`: `FLOAT8` the search radius in meters. Must be greater than zero.
* `min_points`: `INT` the minimum number of points, including the point itself, required to form a dense neighborhood. Must be at least 1.
* `partition_column`: `VARCHAR` optional name of a column to cluster within. When provided, points are clustered independently for each distinct value, and `cluster_id` restarts at zero in every partition. When omitted, the whole input is treated as a single set.

**Output columns**

* every column of `input`
* `cluster_id`: `BIGINT` zero-based cluster index, or `NULL` for points that are not in any cluster.
* `pt_type`: `VARCHAR(8)` one of `core`, `border`, `noise`, or `skipped`. `skipped` marks rows that were excluded from the clustering because the geometry, or the partition value, was `NULL`.

````hint:info
**info**

Cluster assignments match `sklearn.cluster.DBSCAN` with `metric='haversine'` for the same `epsilon` and `min_points`. Where DBSCAN is inherently ambiguous — a border point reachable from two clusters — this implementation always picks the cluster with the lowest canonical label, so results are deterministic and reproducible across runs.

If you are porting a query from BigQuery, `epsilon` is the same parameter as in the native `ST_CLUSTERDBSCAN(geography_column, epsilon, minimum_geographies)`, and `min_points` corresponds to `minimum_geographies`.

````

````hint:warning
**warning**

Only `POINT` geometries are supported. Runtime is driven by point *density* rather than row count: the cost grows with the number of points that fall within `epsilon` of each other, so a very large radius over a tightly packed area is the expensive case.

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
