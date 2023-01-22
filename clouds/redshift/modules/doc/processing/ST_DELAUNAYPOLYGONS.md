## ST_DELAUNAYPOLYGONS

```sql:signature
carto.ST_DELAUNAYPOLYGONS(points)
```

**Description**

Calculates the Delaunay triangulation of the points provided. A MultiPolygon object is returned.

* `points`: `GEOMETRY` MultiPoint input to the Delaunay triangulation.

**Return type**

`VARCHAR(MAX)`

**Example**

```sql
SELECT carto.ST_DELAUNAYPOLYGONS(
  ST_GEOMFROMTEXT(
    'MULTIPOINT((-70.3894720672732 42.9988854818585),(-71.1048188482079 42.6986831053718),(-72.6818783178395 44.1191152795997),(-73.8221894711314 35.1057463244819))'
  )
);
-- {"type": "MultiPolygon", "coordinates": [[[[-71.1048188482, 42.6986831054], [-70.3894720673, 42.9988854819], [-73.8221894711, 35.1057463245], [-71.1048188482, 42.6986831054]]], ...
```