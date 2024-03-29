## S2_BOUNDARY

```sql:signature
S2_BOUNDARY(id)
```

**Description**

Returns the boundary for a given S2 cell ID. We extract the boundary by getting the corner longitudes and latitudes, then enclose it in a GeoJSON and finally transform it into geography.

* `id`: `INT64` S2 cell ID to get the boundary geography from.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT carto.S2_BOUNDARY(955378847514099712);
-- POLYGON((-3.41955272426037 40.25850071217, -3.41955272426037  ...
```

````hint:info
S2 Cell edges are spherical geodesics. The boundary edges can be interpreted as straight lines in other GIS tools, so to export the exact shape of the cells, use `ST_GEOGFROM(ST_ASGEOJSON(geog)`. In this process, BigQuery will add intermediate points to preserve the geodesic curves.
````
