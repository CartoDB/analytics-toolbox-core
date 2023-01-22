## ST_BEZIERSPLINE

```sql:signature
carto.ST_BEZIERSPLINE(geog, resolution, sharpness)
```

**Description**

Takes a line and returns a curved version of it by applying a Bezier spline algorithm. Note that the resulting geography will be a LineString with additional points inserted.

* `geog`: `GEOGRAPHY` input LineString.
* `resolution`: `INT64`|`NULL` total time in milliseconds assigned to the line. If `NULL` the default value `10000` is used. Internal curve vertices are generated in 10 ms increments, so the maximum number of resulting points will be `resolution/10` (close points may be merged resulting in less points). A higher number will increase the accuracy of the result but will increase the computation time and number of points.
* `sharpness`: `FLOAT64`|`NULL` a measure of how curvy the path should be between splines. If `NULL` the default value `0.85` is used.


**Example**


```sql
SELECT `carto-os`.carto.ST_BEZIERSPLINE(
  ST_GEOGFROMTEXT(
    "LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)"
  ),
  10000,
  0.9
);
-- LINESTRING(-76.091308 18.427501, -76.0916216712943 ...
```

{% hint style="info" %}
**ADDITIONAL EXAMPLES**


* [Identifying earthquake-prone areas in the state of California](/analytics-toolbox-bigquery/examples/identifying-earthquake-prone-areas-in-the-state-of-california/)

{% endhint %}