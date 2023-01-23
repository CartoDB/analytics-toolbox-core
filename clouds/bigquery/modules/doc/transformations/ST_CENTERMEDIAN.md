## ST_CENTERMEDIAN

```sql:signature
carto.ST_CENTERMEDIAN(geog)
```

**Description**

Takes a FeatureCollection of points and computes the median center. The median center is understood as the point that requires the least total travel from all other points.

* `geog`: `GEOGRAPHY` feature for which to compute the center.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT `carto-os`.carto.ST_CENTERMEDIAN(
  ST_GEOGFROMTEXT("POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))")
);
-- POINT(25.3783930513609 29.8376035441371)
```
