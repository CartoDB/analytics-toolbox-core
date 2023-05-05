## S2_BOUNDARY

```sql:signature
S2_BOUNDARY(id)
```

**Description**

Returns the boundary for a given S2 cell ID. We extract the boundary by getting the corner longitudes and latitudes, then enclose it in a GeoJSON and finally transform it into geography.

* `id`: `BIGINT` S2 cell ID to get the boundary geography from.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT carto.S2_BOUNDARY(955378847514099712);
-- { "coordinates": [ [ [ -3.743508991266907, 40.24850114133136 ], [ -3.743508991266907, 40.57421345060903 ] ...
```

````hint:info
S2 Cell edges are spherical geodesics.
````
