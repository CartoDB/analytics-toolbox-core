## ST_X

```sql:signature
ST_X(geom)
```

**Description**

If _geom_ is a `Point`, return the X coordinate of that point.

* `geom`: `Geometry` input Point.

**Return type**

`Double`

**Example**

```sql
SELECT carto.ST_X(carto.ST_GEOMFROMWKT('POINT(-76.09130 18.42750)'));
-- -76.09131
```
