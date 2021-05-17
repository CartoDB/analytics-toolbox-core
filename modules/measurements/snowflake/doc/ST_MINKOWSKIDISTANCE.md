### ST_MINKOWSKIDISTANCE

{{% bannerNote type="code" %}}
measurements.ST_MINKOWSKIDISTANCE(geog, p)
{{%/ bannerNote %}}

**Description**

Calculate the Minkowski p-norm distance between two features. https://github.com/Turfjs/turf/tree/master/packages/turf-distance-weight

* `geog`: `ARRAY<GEOGRAPHY>` featureCollection.
* `p`: `FLOAT64` minkowski p-norm distance parameter. 1: Manhattan distance. 2: Euclidean distance. 1 =< p <= infinity. If `NULL` the default value `2` is used.

**Return type**

`ARRAY<STRING>`

**Example**

``` sql
SELECT bqcarto.measurements.ST_MINKOWSKIDISTANCE([ST_GEOGPOINT(10,10),ST_GEOGPOINT(13,10)],2);
-- ["0,0.3333333333333333","0.3333333333333333,0"]
```