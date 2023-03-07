## ST_CENTEROFMASS

```sql:signature
ST_CENTEROFMASS(geog)
```

**Description**

Takes any Feature or a FeatureCollection and returns its center of mass (also known as centroid).

* `geog`: `GEOGRAPHY` feature to be centered.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT carto.ST_CENTEROFMASS(
  ST_GEOGFROMTEXT("POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))")
);
-- POINT(25.1730977433239 27.2789529273059)
```
