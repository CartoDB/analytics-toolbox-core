## ST_VORONOILINES

```sql:signature
carto.ST_VORONOILINES(points)
```

**Description**

Calculates the Voronoi diagram of the points provided. A MultiLineString object is returned.

* `points`: `GEOMETRY` MultiPoint input to the Voronoi diagram.

**Return type**

`VARCHAR(MAX)`

**Example**

```sql
SELECT carto.ST_VORONOILINES(
  ST_GEOMFROMTEXT(
    'MULTIPOINT((-74.5366825512491 43.6889777784079),(-74.4821382017478 43.3096147774153),(-70.7632814028801 42.9679602005825))'
  )
);
-- {"type": "MultiLineString", "coordinates": [[[-72.563891028, 43.7790206765], [-72.6715241053, 42.6074514117]], [[-72.563891028, 43.7790206765], ...
```