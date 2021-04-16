## transformation

<div class="badge core"></div>

### ST_BUFFER

{{% bannerNote type="code" %}}
transformation.ST_BUFFER(geog, radius, units, steps)
{{%/ bannerNote %}}

**Description**

Calculates a Geography buffer for input features for a given radius. Units supported are miles, kilometers, and degrees. https://turfjs.org/docs/#buffer

* `geog`: `GEOGRAPHY` input to be buffered.
* `radius`: `FLOAT64` distance to draw the buffer (negative values are allowed).
* `units`: `STRING` any of the options supported by turf units: miles, kilometers, and degrees.
* `steps`: `INT64` number of steps.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT bqcarto.transformation.ST_BUFFER(ST_GEOGPOINT(-74.00, 40.7128), 1, 'kilometers', 10);
-- POLYGON((-73.9881354374691 40.7127993926494 ... 
```

### VERSION

{{% bannerNote type="code" %}}
transformation.VERSION()
{{%/ bannerNote %}}

**Description**

Returns the current version of the transformation module.

**Return type**

`STRING`

**Example**

```sql
SELECT bqcarto.transformation.VERSION();
-- 1.0.0
```
