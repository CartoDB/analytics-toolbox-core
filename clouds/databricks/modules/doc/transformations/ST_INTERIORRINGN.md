## ST_INTERIORRINGN

```sql:signature
carto.ST_INTERIORRINGN(geom, n)
```

**Description**

Returns a `LineString` representing the exterior ring of the geometry; returns null if the `Geometry` is not a `Polygon`.

* `geom`: `Geometry` input geom.
* `n`: `Int` nth ring to take.

**Return type**

`LineString`

**Example**

```sql
WITH t AS (
  SELECT carto.ST_GEOMFROMWKT("POLYGON ((10 10, 110 10, 110 110, 10 110, 10 10), (20 20, 20 30, 30 30, 30 20, 20 20), (40 20, 40 30, 50 30, 50 20, 40 20))") AS geom
)
SELECT carto.ST_ASTEXT(carto.ST_INTERIORRINGN(geom, 1)) FROM t;
-- LINESTRING (20 20, 20 30, 30 30, 30 20, 20 20)
```
