## ST_CLUSTERKMEANS

```sql:signature
ST_CLUSTERKMEANS(geog, numberOfClusters)
```

**Description**

Takes a set of points as input and partitions them into clusters using the k-means algorithm. Returns an array of tuples with the cluster index for each of the input features and the input geometry.

* `geog`: `ARRAY<GEOGRAPHY>` points to be clustered.
* `numberOfClusters`: `INT64`|`NULL` numberOfClusters that will be generated. If `NULL` the default value `Math.sqrt(<NUMBER OF POINTS>/2)` is used.  The output number of cluster cannot be greater to the number of distinct points of the `geog`.

**Return type**

`ARRAY<STRUCT<cluster INT64, geom GEOGRAPHY>>`

**Example**

```sql
SELECT carto.ST_CLUSTERKMEANS([ST_GEOGPOINT(0, 0), ST_GEOGPOINT(0, 1), ST_GEOGPOINT(5, 0), ST_GEOGPOINT(1, 0)], 2);
-- {cluster: 1, geom: POINT(0 0)}
-- {cluster: 1, geom: POINT(0 1)}
-- {cluster: 0, geom: POINT(5 0)}
-- {cluster: 1, geom: POINT(1 0)}
```
