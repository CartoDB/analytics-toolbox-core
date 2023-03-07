## ST_TRANSLATE

```sql:signature
ST_TRANSLATE(geom, deltaX, deltaY)
```

**Description**

Returns the `Geometry` produced when _geom_ is translated by _deltaX_ and _deltaY_.

* `geom`: `Geometry` input geom.
* `deltaX`: `Double` distance x to be tralslated.
* `deltaY`: `Double` distance y to be tralslated.

**Return type**

`Geometry`

**Example**

```sql
WITH t AS (
  SELECT carto.ST_POINT(0, 0) AS point
)
SELECT carto.ST_ASTEXT(carto.ST_TRANSLATE(point, 1, 2)) FROM t;
-- POINT (1 2)
```
