### ST_DELAUNAYLINES

{{% bannerNote type="code" %}}
processing.ST_DELAUNAYLINES(points)
{{%/ bannerNote %}}

**Description**

Calculates the Delaunay triangulation of the points provided. A MultiLineString object is returned.

* `points`: `GEOMETRY` MultiPoint input to the Delaunay triangulation.

**Return type**

`VARCHAR(MAX)`

**Example**

```sql
SELECT processing.ST_DELAUNAYLINES(ST_GEOMFROMTEXT('MULTIPOINT((-70.3894720672732 42.9988854818585),(-71.1048188482079 42.6986831053718),(-72.6818783178395 44.1191152795997),(-73.8221894711314 35.1057463244819))'));
-- {"coordinates": [[[-71.104819, 42.698683], [-70.389472, 42.998885], [-73.822189, 35.105746], [-71.104819, 42.698683]], [[-71.104819, 42.698683], [-72.681878, 44.119115], [-73.822189, 35.105746], [-71.104819, 42.698683]], [[-71.104819, 42.698683], [-72.681878, 44.119115], [-70.389472, 42.998885], [-71.104819, 42.698683]]], "type": "MultiLineString"}
```