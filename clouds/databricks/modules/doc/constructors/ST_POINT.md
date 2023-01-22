## ST_POINT

```sql:signature
carto.ST_POINT(x, y)
```

**Description**

Returns a `Point` with the given coordinate values. This is an OGC alias for st_makePoint.

* `x`: `Double` input x value of the point.
* `y`: `Double` input y value of the point.

**Return type**

`Point`

**Example**

```sql
SELECT carto.ST_ASTEXT(carto.ST_POINT(-91.85548, 29.50603));
-- POINT (-91.85548 29.50603)
```