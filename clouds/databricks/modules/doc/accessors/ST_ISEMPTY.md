## ST_ISEMPTY

```sql:signature
carto.ST_ISEMPTY(geom)
```

**Description**

Returns `true` if _geom_ is an empty geometry.

* `geom`: `Geometry` input geom.

**Return type**

`Boolean`

**Example**

```sql
SELECT carto.ST_ISEMPTY(carto.ST_GEOMFROMWKT("LINESTRING EMPTY"));
-- true
```
