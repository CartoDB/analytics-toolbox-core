## ST_ISGEOMFIELD

```sql:signature
carto.ST_ISGEOMFIELD(geom)
```

**Description**

Returns `true` if _geom_ is string containing WKT or WKB representation of a geometry.

* `geom`: `Geometry` input geom.

**Return type**

`Boolean`

**Example**

```sql
SELECT carto.ST_ISGEOMFIELD("LINESTRING(1 1, 2 3)");
-- true
```
