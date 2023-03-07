## ST_MAKEPOINTM

```sql:signature
ST_MAKEPOINTM(x, y, z)
```

**Description**

Creates a `Point` with an _x_, _y_, and _m_ coordinate.

* `x`: `Double` input x value of the point.
* `y`: `Double` input y value of the point.
* `z`: `Double` input z value of the point.

**Return type**

`Point`

**Example**

```sql
SELECT carto.ST_MAKEPOINTM(-91.8554869, 29.5060349, 5);
-- BINARY OUTPUT - 4QgB6aOA7Ab6jbKZAgo=
```
