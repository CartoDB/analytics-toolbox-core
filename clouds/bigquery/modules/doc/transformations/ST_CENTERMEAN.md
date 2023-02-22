## ST_CENTERMEAN

```sql:signature
carto.ST_CENTERMEAN(geog)
```

**Description**

Takes a Feature or FeatureCollection and returns the mean center (average of its vertices).

* `geog`: `GEOGRAPHY` feature for which to compute the center.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT carto.ST_CENTERMEAN(
  ST_GEOGFROMTEXT("POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))")
);
-- POINT(25.3890912155939 29.7916831655627)
```
