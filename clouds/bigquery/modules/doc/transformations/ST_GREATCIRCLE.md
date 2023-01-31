## ST_GREATCIRCLE

```sql:signature
carto.ST_GREATCIRCLE(startPoint, endPoint, npoints)
```

**Description**

Calculate great circle routes as LineString or MultiLineString. If the start and end points span the antimeridian, the resulting feature will be split into a MultiLineString.

* `startPoint`: `GEOGRAPHY` source point feature.
* `endPoint`: `GEOGRAPHY` destination point feature.
* `npoints`: `INT64`|`NULL` number of points. If `NULL` the default value `100` is used.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT `carto-os`.carto.ST_GREATCIRCLE(ST_GEOGPOINT(-3.70325,40.4167), ST_GEOGPOINT(-73.9385,40.6643), 20);
-- LINESTRING(-3.70325 40.4167 ...
```
