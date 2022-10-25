### ST_VORONOILINES

{{% bannerNote type="code" %}}
carto.ST_VORONOILINES(points, bbox)
{{%/ bannerNote %}}

**Description**

Calculates the Voronoi diagram of the points provided. An array of lines is returned.

* `points`: `ARRAY<GEOGRAPHY>` input to the Voronoi diagram.
* `bbox`: `ARRAY<FLOAT64>|NULL` clipping bounding box. If `NULL` a default [-180,-85,180,-85] bbox will be used.

Due to technical limitations of the underlying libraries used, the input points' coordinates are truncated to 5 decimal places in order to avoid problems that happen with close but distinct input points. This limits the precision of the results and can alter slightly the position of the resulting lines (about 1 meter). This can also result in some points being merged together, so that fewer lines than input points may result.

**Return type**

`ARRAY<GEOGRAPHY>`

{{% customSelector %}}
**Examples**
{{%/ customSelector %}}

``` sql
SELECT `carto-os`.carto.ST_VORONOILINES(
  [
    ST_GEOGPOINT(-75.833, 39.284),
    ST_GEOGPOINT(-75.6, 39.984),
    ST_GEOGPOINT(-75.221, 39.125)
  ],
  [-76.0, 39.0, -75.0, 40.0]
);
-- LINESTRING(-76 39.728365, -75.8598447436013 39.6817133217987, ...
-- LINESTRING(-75 39.7356169965076, -75.2196894872026 39.6386876418512, ...
-- LINESTRING(-75.5801299019608 39, -75.509754438183 39.2708791435974, ...
```

Note that if some points are very close together (about 1 meter) they may be merged and the result may have fewer lines than points, for example these three points result in two lines

```sql
SELECT `carto-os`.carto.ST_VORONOILINES(
     [
          ST_GEOGPOINT(4.1829523,43.6347910),
          ST_GEOGPOINT(4.1829967,43.6347137),
          ST_GEOGPOINT(4.1829955,43.6347143)
     ],
     [4.182, 43.634, 4.183, 43.635]
);
-- [
--   LINESTRING(4.183 43.634765625, 4.182 43.634140625, 4.182 43.635, 4.183 43.635, 4.183 43.634765625),
--   LINESTRING(4.182 43.634140625, 4.183 43.634765625, 4.183 43.634, 4.182 43.634, 4.182 43.634140625)
--  ]
```
