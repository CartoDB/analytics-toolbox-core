## ST_CENTERMEDIAN

```sql:signature
carto.ST_CENTERMEDIAN(geog)
```

**Description**

Takes a FeatureCollection of points and computes the median center. The median center is understood as the point that requires the least total travel from all other points.

* `geog`: `GEOGRAPHY` for which to compute the center.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT carto.ST_CENTERMEDIAN(TO_GEOGRAPHY('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))'));
-- { "coordinates": [ 25, 27.5 ], "type": "Point" }
```
