## ST_POINTN

```sql:signature
ST_POINTN(geom, n)
```

**Description**

If _geom_ is a `LineString`, returns the _n_-th vertex of _geom_ as a `Point`. Negative values are counted backwards from the end of the `LineString`. Returns `null` if _geom_ is not a `LineString`.

* `geom`: `Geometry` input geom.
* `n`: `Int` input number of vertex to take.

**Return type**

`Point`

**Example**

```sql
SELECT carto.ST_ASTEXT(
  carto.ST_POINTN(
    carto.ST_GEOMFROMWKT(
      "LINESTRING(1 1, 2 3, 4 4, 3 4)"),
      3
    )
  );
-- POINT (4 4)
```
