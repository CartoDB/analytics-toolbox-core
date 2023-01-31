## ST_GREATCIRCLE

```sql:signature
carto.ST_GREATCIRCLE(startPoint, endPoint [, npoints])
```

**Description**

Calculate great circle routes as LineString or MultiLineString. If the start and end points span the antimeridian, the resulting feature will be split into a MultiLineString.

* `startPoint`: `GEOGRAPHY` source point feature.
* `endPoint`: `GEOGRAPHY` destination point feature.
* `npoints` (optional): `INT` number of points. By default `npoints` is `100`.

**Return type**

`GEOGRAPHY`

**Examples**

```sql
SELECT carto.ST_GREATCIRCLE(ST_POINT(-3.70325,40.4167), ST_POINT(-73.9385,40.6643));
-- { "coordinates": [ [ -3.7032499999999993, 40.4167 ], ...
```

```sql
SELECT carto.ST_GREATCIRCLE(ST_POINT(-3.70325,40.4167), ST_POINT(-73.9385,40.6643), 20);
-- { "coordinates": [ [ -3.7032499999999993, 40.4167 ], ...
```
