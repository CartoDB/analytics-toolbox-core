### ST_CENTERMEDIAN

{{% bannerNote type="code" %}}
transformations.ST_CENTERMEDIAN(geog)
{{%/ bannerNote %}}

**Description**

Takes a FeatureCollection of points and calculates the median center, algorithimically. The median center is understood as the point that is requires the least total travel from all other points. https://github.com/Turfjs/turf/tree/master/packages/turf-center-median

* `geog`: `GEOGRAPHY` feature to be centered.

**Return type**

`GEOGRAPHY`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

``` sql
SELECT carto-os.transformations.ST_CENTERMEDIAN(ST_GEOGFROMTEXT("POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))"));
-- POINT(25.3783930513609 29.8376035441371)
```