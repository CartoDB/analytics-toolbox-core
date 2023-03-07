## ST_ISCOLLECTION

```sql:signature
ST_ISCOLLECTION(geom)
```

**Description**

Returns `true` if _geom_ is a `GeometryCollection`.

* `geom`: `Geometry` input geom.

**Return type**

`Boolean`

**Example**

```sql
SELECT carto.ST_ISCOLLECTION(
  carto.ST_GEOMFROMWKT(
    "GEOMETRYCOLLECTION(LINESTRING(1 1, 2 3), POINT(0 4)), LINESTRING EMPTY"
  )
);
-- true
```
