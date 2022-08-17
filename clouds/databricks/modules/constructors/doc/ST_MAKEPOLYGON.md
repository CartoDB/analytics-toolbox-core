### ST_MAKEPOLYGON

{{% bannerNote type="code" %}}
carto.ST_MAKEPOLYGON(shell)
{{%/ bannerNote %}}

**Description**

Creates a `Polygon` formed by the given `LineString` shell, which must be closed.

* `shell`: `LineString` input linestring closed.

**Return type**

`Polygon`

**Example**

```sql
SELECT ST_ASTEXT(ST_MAKEPOLYGON( ST_GEOMFROMWKT('LINESTRING(75 29,77 29,77 27, 75 29)')));
-- POLYGON ((75 29, 77 29, 77 27, 75 29))
```
