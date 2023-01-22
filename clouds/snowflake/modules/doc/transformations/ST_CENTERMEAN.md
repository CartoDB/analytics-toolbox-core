## ST_CENTERMEAN

```sql:signature
carto.ST_CENTERMEAN(geog)
```

**Description**

Takes a Feature or FeatureCollection and returns the mean center (average of its vertices).

* `geom`: `GEOGRAPHY` for which to compute the mean center.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT carto.ST_CENTERMEAN(TO_GEOGRAPHY('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))'));
-- { "coordinates": [ 26, 24 ], "type": "Point" }
```