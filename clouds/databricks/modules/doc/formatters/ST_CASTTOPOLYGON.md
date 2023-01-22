## ST_CASTTOPOLYGON

```sql:signature
carto.ST_CASTTOPOLYGON(geom)
```

**Description**

Casts `Geometry` _g_ to a `Polygon`.

* `geom`: `Geometry` input geom.

**Return type**

`Polygon`

**Example**

```sql
SELECT carto.ST_CASTTOPOLYGON(carto.ST_GEOMFROMWKT('POLYGON((75 29, 77 29, 77 27, 75 29))'));
-- 4wgBAQSA3qDLBYCyyJQCAIC0iRMAAAD/s4kTAP+ziROAtIkTAA==
```