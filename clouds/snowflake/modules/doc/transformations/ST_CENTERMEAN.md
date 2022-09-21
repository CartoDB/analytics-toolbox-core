### ST_CENTERMEAN

{{% bannerNote type="code" %}}
carto.ST_CENTERMEAN(geog)
{{%/ bannerNote %}}

**Description**

Takes a Feature or FeatureCollection and returns the mean center.

* `geog`: `GEOGRAPHY` feature to be centered.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT carto.ST_CENTERMEAN(TO_GEOGRAPHY('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))'));
-- { "coordinates": [ 26, 24 ], "type": "Point" }
```
