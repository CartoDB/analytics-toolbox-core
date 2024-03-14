## ST_GENERATEPOINTS

```sql:signature
ST_GENERATEPOINTS(geog, npoints)
```

**Description**

Generates randomly placed points inside a polygon and returns them in an array of geographies.

The distribution of the generated points is spherically uniform (i.e. if the coordinates are interpreted as longitude and latitude on a sphere); this means that WGS84 coordinates will be only approximately uniformly distributed, since WGS84 is based on an ellipsoidal model.

* `geog`: `GEOGRAPHY` a polygon; the random points generated will be inside this polygon.
* `npoints`: `INT` number of points to generate.

**Constraints**

`npoints` must not exceed 100000.

**Return type**

`ARRAY`

**Example**

```sql
SELECT carto.ST_GENERATEPOINTS(TO_GEOGRAPHY('POLYGON((0 0, 10 0, 10 10, 0 0))'), 100);
-- "{\"coordinates\":[6.781385759749447e+00,9.240795947965740e-01],\"type\":\"Point\"}"
-- "{\"coordinates\":[9.993805698147805e+00,5.083022246239731e+00],\"type\":\"Point\"}"
-- "{\"coordinates\":[3.228015360947772e+00,5.353450085600810e-01],\"type\":\"Point\"}"
-- ...
```
