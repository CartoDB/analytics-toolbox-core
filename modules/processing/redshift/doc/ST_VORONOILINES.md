### ST_VORONOILINES

{{% bannerNote type="code" %}}
processing.ST_VORONOILINES(points)
{{%/ bannerNote %}}

**Description**

Calculates the Voronoi diagram of the points provided. A MultiLineString object is returned.

* `points`: `GEOMETRY` MultiPoint input to the Voronoi diagram.


**Return type**

`VARCHAR(MAX)`

**Example**

```sql
SELECT processing.ST_VORONOILINES(ST_GEOMFROMTEXT('MULTIPOINT((-74.5366825512491 43.6889777784079),(-74.4821382017478 43.3096147774153),(-70.7632814028801 42.9679602005825))'))
-- {"coordinates": [[[-72.56389, 43.779024], [-72.671524, 42.607451]], [[-72.56389, 43.779024], [-74.897192, 43.443541]], [[-72.56389, 43.779024], [-72.512211, 44.049487]]], "type": "MultiLineString"}
```