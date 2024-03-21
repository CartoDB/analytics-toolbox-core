## ST_GENERATEPOINTS

```sql:signature
ST_GENERATEPOINTS(geog, npoints)
```

**Description**

Generates randomly placed points inside a polygon and returns them in an array of geographies.

The distribution of the generated points is spherically uniform (i.e. if the coordinates are interpreted as longitude and latitude on a sphere); this means that WGS84 coordinates will be only approximately uniformly distributed, since WGS84 is based on an ellipsoidal model.

* `geog`: `GEOMETRY` a polygon; the random points generated will be inside this polygon.
* `npoints`: `INT` number of points to generate.

**Constraints**

`npoints` must not exceed `1000`.

**Return type**

`VARCHAR(MAX)`

**Example**

```sql
SELECT carto.ST_GENERATEPOINTS(ST_GEOMFROMTEXT('POLYGON((0 0, 10 0, 10 10, 0 0))'), 100);
-- {"type": "MultiPoint", "coordinates": [[8.383157939015296, 1.062699131285872], ...
```
