### ST_MAKEENVELOPE

{{% bannerNote type="code" %}}
carto.ST_MAKEENVELOPE(xmin, ymin, xmax, ymax)
{{%/ bannerNote %}}

**Description**
Creates a rectangular Polygon from the minimum and maximum values for X and Y.

* `xmin`: `FLOAT8` minimum value for X.
* `ymin`: `FLOAT8` minimum value for Y.
* `xmax`: `FLOAT8` maximum value for X.
* `ymax`: `FLOAT8` maximum value for Y.

**Return type**

`GEOMETRY`

**Example**

```sql
SELECT carto.ST_MAKEENVELOPE(0, 0, 1, 1);
-- POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))
```
