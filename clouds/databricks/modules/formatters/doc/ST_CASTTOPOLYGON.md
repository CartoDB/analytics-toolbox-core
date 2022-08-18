### st_castToPolygon
`Polygon st_castToPolygon(Geometry g)`

Casts `Geometry` _g_ to a `Polygon`.

### ST_CASTTOPOLYGON

{{% bannerNote type="code" %}}
carto.ST_CASTTOPOLYGON(geom)
{{%/ bannerNote %}}

**Description**

Casts `Geometry` _g_ to a `Polygon`.

* `geom`: `Geometry` input geom.

**Return type**

`Polygon`

**Example**

```sql
SELECT ST_CASTTOPOLYGON(ST_GEOMFROMWKT('POLYGON((75 29, 77 29, 77 27, 75 29))'))
-- 4wgBAQSA3qDLBYCyyJQCAIC0iRMAAAD/s4kTAP+ziROAtIkTAA==
```