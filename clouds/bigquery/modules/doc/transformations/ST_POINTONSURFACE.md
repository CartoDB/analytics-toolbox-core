## ST_POINTONSURFACE

```sql:signature
ST_POINTONSURFACE(geog)
```

**Description**

Takes any Feature or a FeatureCollection and returns a point that is granted to be inside one of the polygons.

* `geog`: `GEOGRAPHY` feature to be centered.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT carto.ST_POINTONSURFACE(
  ST_GEOGFROMTEXT("POLYGON ((1.444057 38.791203 ,  1.450457 38.793763 ,  1.457178 38.792403 ,  1.458298 38.781282 ,  1.453418 38.778242 ,  1.445977 38.780482 ,  1.453498 38.781042 ,  1.456218 38.786883 ,  1.450617 38.790643 ,  1.444057 38.791203))")
);
-- POINT(1.456218 38.786883)
```
