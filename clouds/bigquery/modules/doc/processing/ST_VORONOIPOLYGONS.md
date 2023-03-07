## ST_VORONOIPOLYGONS

```sql:signature
ST_VORONOIPOLYGONS(points, bbox)
```

**Description**

Calculates the Voronoi diagram of the points provided. An array of polygons is returned.

* `points`: `ARRAY<GEOGRAPHY>` input to the Voronoi diagram.
* `bbox`: `ARRAY<FLOAT64>|NULL` clipping bounding box. If `NULL` a default [-180,-85,180,-85] bbox will be used.

Due to technical limitations of the underlying libraries used, the input points' coordinates are truncated to 5 decimal places in order to avoid problems that happen with close but distinct input points. This limits the precision of the results and can alter slightly the position of the resulting polygons (about 1 meter). This can also result in some points being merged together, so that fewer polygons than input points may result.

**Return type**

`ARRAY<GEOGRAPHY>`

**Examples**

```sql
SELECT carto.ST_VORONOIPOLYGONS(
  [
    ST_GEOGPOINT(-75.833, 39.284),
    ST_GEOGPOINT(-75.6, 39.984),
    ST_GEOGPOINT(-75.221, 39.125)
  ],
  [-76.0, 39.0, -75.0, 40.0]
);
-- POLYGON((-76 39, -75.7900649509804 39, -75.5801299019608 39, ...
-- POLYGON((-75 40, -75.25 40, -75.5 40, -75.75 40, -76 40, ...
-- POLYGON((-75.43509742git64706 39, -75.2900649509804 39, ...
```

Note that if some points are very close together (about 1 meter) they may be merged and the result may have fewer polygons than points, for example these three points result in two polygons:

```sql
SELECT carto.ST_VORONOIPOLYGONS(
     [
          ST_GEOGPOINT(4.1829523,43.6347910),
          ST_GEOGPOINT(4.1829967,43.6347137),
          ST_GEOGPOINT(4.1829955,43.6347143)
     ],
     [4.182, 43.634, 4.183, 43.635]
);
-- [
--   POLYGON((4.183 43.635, 4.182 43.635, 4.182 43.634140625, 4.183 43.634765625, 4.183 43.635)),
--   POLYGON((4.182 43.634, 4.183 43.634, 4.183 43.634765625, 4.182 43.634140625, 4.182 43.634))
-- ]
```
