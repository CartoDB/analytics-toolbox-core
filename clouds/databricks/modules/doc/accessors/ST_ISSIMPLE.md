## ST_ISSIMPLE

```sql:signature
ST_ISSIMPLE(geom)
```

**Description**

Returns `true` if _geom_ has no anomalous geometric points, such as self intersection or self tangency.

* `geom`: `Geometry` input geom.

**Return type**

`Boolean`

**Example**

```sql
SELECT carto.ST_ISSIMPLE(carto.ST_GEOMFROMWKT("LINESTRING(1 1, 2 3, 4 3, 2 3)"));
-- false
```
