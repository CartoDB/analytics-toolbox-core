## ST_MAKEENVELOPE

```sql:signature
carto.ST_MAKEENVELOPE(xmin, ymin, xmax, ymax)
```

**Description**
Creates a rectangular Polygon from the minimum and maximum values for X and Y.

* `xmin`: `DOUBLE` minimum value for X.
* `ymin`: `DOUBLE` minimum value for Y.
* `xmax`: `DOUBLE` maximum value for X.
* `ymax`: `DOUBLE` maximum value for Y.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT carto.ST_MAKEENVELOPE(0,0,1,1);
-- { "coordinates": [ [ [ 0, 0 ], [ 0, 1 ], [ 1, 1 ], [ 1, 0 ], [ 0, 0 ] ] ], "type": "Polygon" }
```