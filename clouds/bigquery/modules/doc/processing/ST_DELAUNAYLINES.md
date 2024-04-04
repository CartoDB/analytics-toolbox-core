## ST_DELAUNAYLINES

```sql:signature
ST_DELAUNAYLINES(points)
```

**Description**

Calculates the Delaunay triangulation of the points provided. An array of line strings is returned.

* `points`: `ARRAY<GEOGRAPHY>` input to the Delaunay triangulation.

Due to technical limitations of the underlying libraries used, the input points' coordinates are truncated to 5 decimal places in order to avoid problems that happen with close but distinct input points. This limits the precision of the results and can alter slightly the position of the resulting polygons (about 1 meter). This can also result in some points being merged together, so that fewer polygons than expected may result.

````hint:warning
**warning**

The maximum number of points typically used to compute Delaunay diagrams is 300,000. This limit ensures efficient computation while maintaining accuracy in delineating regions based on proximity to specified points.
````

**Return type**

`ARRAY<GEOGRAPHY>`

**Examples**

```sql
SELECT carto.ST_DELAUNAYLINES(
  [
    ST_GEOGPOINT(-74.5366825512491, 43.6889777784079),
    ST_GEOGPOINT(-74.4821382017478, 43.3096147774153),
    ST_GEOGPOINT(-70.7632814028801, 42.9679602005825),
    ST_GEOGPOINT(-73.3262122666779, 41.2706174323278),
    ST_GEOGPOINT(-70.2005131676838, 43.8455720129728),
    ST_GEOGPOINT(-73.9704330709753, 35.3953164724094),
    ST_GEOGPOINT(-72.3402283537205, 35.8941454568627),
    ST_GEOGPOINT(-72.514071762468, 36.5823995124737)
  ]
);
-- LINESTRING(-74.5366825512491 43.6889777784079, -70.7632814028801 ...
-- LINESTRING(-74.4821382017478 43.3096147774153, -74.5366825512491  ...
-- LINESTRING(-73.3262122666779 41.2706174323278, -74.4821382017478 ...
-- LINESTRING(-73.9704330709753 35.3953164724094, -72.3402283537205 ...
-- LINESTRING(-73.9704330709753 35.3953164724094, -72.514071762468 ...
-- LINESTRING(-72.514071762468 36.5823995124737, -73.3262122666779 ...
```

Note that if some points are very close together (about 1 meter) they may be merged and the result may have fewer lines than expected, for example these four points result in two lines:

```sql
SELECT carto.ST_DELAUNAYLINES(
     [
          ST_GEOGPOINT(4.1829523, 43.6347910),
          ST_GEOGPOINT(4.1829967, 43.6347137),
          ST_GEOGPOINT(4.1829955, 43.6347143),
          ST_GEOGPOINT(4.1829321, 43.6347500)
     ]
);
-- [
--   LINESTRING(4.18293 43.63475, 4.183 43.63471, 4.18295 43.63479, 4.18293 43.63475)
-- ]
```
