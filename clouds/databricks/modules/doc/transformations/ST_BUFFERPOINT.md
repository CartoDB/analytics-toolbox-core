## ST_BUFFERPOINT

```sql:signature
carto.ST_BUFFERPOINT(point, radius)
```

**Description**

Returns a `Geometry` covering all points within a given radius of Point _point_, where radius is given in meters.

Returns the boundary, or an empty `Geometry` of appropriate dimension, if _geom_ is empty.

* `point`: `Point` Center of the buffer.
* `buffer`: `Double` radius in meters.

**Return type**

`Geometry`

**Example**

```sql
SELECT carto.ST_ASTEXT(carto.ST_BUFFERPOINT(carto.ST_POINT(0, 0), 1));;
-- POLYGON ((0.000009 0, 0.000009 0.0000006, 0.0000089 0.0000011, 0.0000088 0.0000017, ...
```
