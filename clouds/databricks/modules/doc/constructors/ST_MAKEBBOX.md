## ST_MAKEBBOX

```sql:signature
carto.ST_MAKEBBOX(lowerX, lowerY, upperX, upperY)
```

**Description**

Creates a `Geometry` representing a bounding box with the given boundaries.

* `lowerX`: `Double` input lower x value.
* `lowerY`: `Double` input lower y value.
* `upperX`: `Double` input upper x value.
* `upperY`: `Double` input upper y value.

**Return type**

`Geometry`

**Example**

```sql
SELECT carto.ST_ASTEXT(
  carto.ST_MAKEBBOX(-91.85548, 29.50603, -91.83820, 29.53073)
) AS bbox;
-- POLYGON ((-91.85548 29.50603, -91.85548 29.53073, -91.83820 29.53073, -91.8382 29.50603, -91.85548 29.50603))
```
