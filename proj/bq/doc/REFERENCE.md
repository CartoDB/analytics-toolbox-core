## Reference

### PROJ

#### VERSION

{{% bannerNote type="code" %}}
proj.VERSION()
{{%/ bannerNote %}}

Returns the current version of the proj library. Here is some sample code block:

#### PROJ

{{% bannerNote type="code" %}}
proj.PROJ(fromProjection STRING, toProjection STRING,coordinates ARRAY<FLOAT64>)
{{%/ bannerNote %}}

Transform point coordinates from one coordinate system to another, including datum transformations.
Projections can be proj or wkt strings. For more information, visit: https://github.com/proj4js/proj4js.
You will also find more information on how to form the projections strings on: https://proj.org/usage/projections.html.

* `fromProjection`: `STRING` initial coordinates system.
* `toProjection`: `STRING` final coordinates system.
* `coordinates`: `ARRAY<FLOAT64>` coordinates to be converted.