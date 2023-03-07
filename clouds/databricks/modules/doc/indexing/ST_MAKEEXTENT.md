## ST_MAKEEXTENT

```sql:signature
ST_MAKEEXTENT(lowerX, lowerY, upperX, upperY)
```

**Description**

Creates a [Extent](https://geotrellis.readthedocs.io/en/latest/guide/core-concepts.html#extents) representing a bounding box with the given boundaries.

* `lowerX`: `Double` input lower x value.
* `lowerY`: `Double` input lower y value.
* `upperX`: `Double` input upper x value.
* `upperY`: `Double` input upper y value.

**Return type**

`Extent`

**Example**

```sql
SELECT carto.ST_MAKEEXTENT(0, 0, 1, 1);
-- {"xmin": 0, "ymin": 0, "xmax": 1, "ymax": 1}
```
