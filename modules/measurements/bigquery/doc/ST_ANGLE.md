### ST_ANGLE

{{% bannerNote type="code" %}}
carto.ST_ANGLE(startPoint, midPoint, endPoint, mercator)
{{%/ bannerNote %}}

**Description**

Finds the angle formed by two adjacent segments defined by 3 points. The result will be the (positive clockwise) angle with origin on the startPoint-midPoint segment, or its explementary angle if required.

* `startPoint`: `GEOGRAPHY` start Point Coordinates.
* `midPoint`: `GEOGRAPHY` mid Point Coordinates.
* `endPoint`: `GEOGRAPHY` end Point Coordinates.
* `mercator`: `BOOLEAN`|`NULL` if calculations should be performed over Mercator or WGS84 projection. If `NULL` the default value `false` is used.

**Return type**

`FLOAT64`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

``` sql
SELECT carto-os.carto.ST_ANGLE(ST_GEOGPOINT(-3.70325 ,40.4167), ST_GEOGPOINT(-4.70325 ,10.4167), ST_GEOGPOINT(-5.70325 ,40.4167), false);
-- 3.933094586038578
```