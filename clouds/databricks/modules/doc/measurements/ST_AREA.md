## ST_AREA

```sql:signature
carto.ST_AREA(geom)
```

**Description**

If `Geometry` _g_ is areal, returns the area of its surface in square units of the coordinate reference system (for example, `degrees^2` for EPSG:4326). Returns `0.0` for non-areal geometries (e.g. `Points`, non-closed `LineStrings`, etc.).

* `geom`: `Geometry` input geom.

**Return type**

`Double`

**Example**

```sql
SELECT carto.ST_AREA(carto.ST_MAKEBBOX(0, 0, 2, 2));
-- 4
```
