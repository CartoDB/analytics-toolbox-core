### ST_MAKEENVELOPE

{{% bannerNote type="code" %}}
constructors.ST_MAKEENVELOPE(xmin, ymin, xma, ymax)
{{%/ bannerNote %}}

**Description**
Creates a rectangular Polygon from the minimum and maximum values for X and Y.


* `xmin`: `FLOAT64` minimum value for X.
* `ymin`: `FLOAT64` minimum value for Y.
* `xmax`: `FLOAT64` maximum value for X.
* `ymax`: `FLOAT64` maximum value for Y.

**Return type**

`GEOGRAPHY`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto-os.constructors.ST_MAKEENVELOPE(0,0,1,1);
-- POLYGON((1 0, 1 1, 0 1, 0 0, 1 0)) 
```