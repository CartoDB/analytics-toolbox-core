## QUADBIN_BOUNDARY

```sql:signature
QUADBIN_BOUNDARY(quadbin)
```

**Description**

Returns the boundary for a given Quadbin as a polygon GEOGRAPHY with the same coordinates as given by the [QUADBIN_BBOX](quadbin#quadbin_bbox) function.

* `quadbin`: `INT64` Quadbin to get the boundary geography from.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT carto.QUADBIN_BOUNDARY(5207251884775047167);
-- POLYGON((-22.5 40.9798980696201, -22.5 21.9430455334382, 0 21.9430455334382, 0 40.9798980696201, -22.5 40.9798980696201))
```

````hint:info
Quadbin Cell edges are spherical geodesics. The boundary edges can be interpreted as straight lines in other GIS tools, so to export the exact shape of the cells, use `ST_GEOGFROM(ST_ASGEOJSON(geog)`. In this process, BigQuery will add intermediate points to preserve the geodesic curves.
````
