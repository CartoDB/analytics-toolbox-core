## constructors

<div class="badge core"></div>

This module contains functions that create geographies from coordinates or already existing geographies.

### ST_MAKEENVELOPE

{{% bannerNote type="code" %}}
transformation.ST_MAKEENVELOPE(xmin, ymin, xma, ymax)
{{%/ bannerNote %}}

**Description**
Creates a rectangular Polygon from the minimum and maximum values for X and Y.


* `xmin`: `FLOAT64` minimum value for X.
* `ymin`: `FLOAT64` minimum value for Y.
* `xmax`: `FLOAT64` maximum value for X.
* `ymax`: `FLOAT64` maximum value for Y.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT bqcarto.constructors.ST_MAKEENVELOPE(0,0,1,1);
-- POLYGON((1 0, 1 1, 0 1, 0 0, 1 0)) 
```

### VERSION

{{% bannerNote type="code" %}}
constructors.VERSION()
{{%/ bannerNote %}}

**Description**

Returns the current version of the constructors module.

**Return type**

`STRING`

**Example**

```sql
SELECT bqcarto.constructors.VERSION();
-- 1.0.0
```