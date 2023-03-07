## ST_ISVALID

```sql:signature
ST_ISVALID(geom)
```

**Description**

Returns `true` if the `Geometry` is topologically valid according to the OGC SFS specification.

* `geom`: `Geometry` input geom.

**Return type**

`Boolean`

**Example**

```sql
SELECT carto.ST_ISVALID(carto.ST_GEOMFROMWKT("POLYGON((0 0, 1 1, 1 2, 1 1, 0 0))"));
-- false
```
