## ST_VORONOIPOLYGONS

```sql:signature
ST_VORONOIPOLYGONS(points)
```

**Description**

Calculates the Voronoi diagram of the points provided. A MultiPolygon object is returned.

* `points`: `GEOMETRY` MultiPoint input to the Voronoi diagram.

````hint:warning
**warning**

The maximum number of points typically used to compute Voronoi diagrams is 300,000. This limit ensures efficient computation while maintaining accuracy in delineating regions based on proximity to specified points.
````

**Return type**

`VARCHAR(MAX)`

**Example**

```sql
SELECT carto.ST_VORONOIPOLYGONS(
  ST_GEOMFROMTEXT(
    'MULTIPOINT((-74.5366825512491 43.6889777784079),(-74.4821382017478 43.3096147774153),(-70.7632814028801 42.9679602005825))'
  )
);
-- {"type": "MultiPolygon", "coordinates": [[[[-74.8971913401, 43.443541604], [-72.563891028, 43.7790206765], [-72.5122106861, 44.0494865673], [-74.8971913401, 44.0494865673], ...
```
