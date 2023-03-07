## ST_ASTEXT

```sql:signature
ST_ASTEXT(geom)
```

**Description**

Returns `Geometry` _geom_ in WKT representation.

* `geom`: `Geometry` input geom.

**Return type**

`String`

**Example**

```sql
SELECT carto.ST_ASTEXT(carto.ST_POINT(-76.09130, 18.42750));
-- POINT (-76.0913 18.4275)
```
