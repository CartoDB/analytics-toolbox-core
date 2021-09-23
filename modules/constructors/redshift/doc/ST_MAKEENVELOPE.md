### ST_MAKEENVELOPE

{{% bannerNote type="code" %}}
constructors.ST_MAKEENVELOPE(xmin, ymin, xma, ymax)
{{%/ bannerNote %}}

**Description**
Creates a rectangular Polygon from the minimum and maximum values for X and Y.

* `xmin`: `FLOAT8` minimum value for X.
* `ymin`: `FLOAT8` minimum value for Y.
* `xmax`: `FLOAT8` maximum value for X.
* `ymax`: `FLOAT8` maximum value for Y.

**Return type**

`GEOMETRY`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT constructors.ST_MAKEENVELOPE(0,0,1,1);
-- POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0)) 
```