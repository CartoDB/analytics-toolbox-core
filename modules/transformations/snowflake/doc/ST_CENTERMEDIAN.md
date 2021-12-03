### ST_CENTERMEDIAN

{{% bannerNote type="code" %}}
carto.ST_CENTERMEDIAN(geog)
{{%/ bannerNote %}}

**Description**

Takes a FeatureCollection of points and calculates the median center, algorithimically. The median center is understood as the point that is requires the least total travel from all other points.

* `geog`: `GEOGRAPHY` feature to be centered.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT carto.ST_CENTERMEDIAN(TO_GEOGRAPHY('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))'));
-- { "coordinates": [ 25, 27.5 ], "type": "Point" }
```