### ST_ISCLOSED

{{% bannerNote type="code" %}}
carto.ST_ISCLOSED(geom)
{{%/ bannerNote %}}

**Description**

Returns `true` if geom is a `LineString` or `MultiLineString` and its start and end points are coincident. Returns true for all other `Geometry` types.

* `geom`: `Geometry` input geom.

**Return type**

`Boolean`

**Example**

```sql
SELECT carto.ST_ISCLOSED(carto.ST_GEOMFROMWKT("LINESTRING(1 1, 2 3, 4 3, 1 1)"));
-- true
```