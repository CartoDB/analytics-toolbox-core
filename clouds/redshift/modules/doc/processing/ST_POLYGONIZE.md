### ST_POLYGONIZE

{{% bannerNote type="code" %}}
carto.ST_POLYGONIZE(lines)
{{%/ bannerNote %}}

**Description**

Creates a polygon from a geography which contains lines that represent its edges.

* `line`: `GEOMETRY` lines which represent the polygon edges.

**Return type**

`GEOMETRY`

**Example**

```sql
SELECT carto.ST_POLYGONIZE(ST_GEOMFROMTEXT('LINESTRING(-74.5366825512491 43.6889777784079, -70.7632814028801 42.9679602005825, -70.2005131676838 43.8455720129728, -74.5366825512491 43.6889777784079)'));
-- POLYGON ((-74.5366825512491 43.6889777784079, -70.7632814028801 42.9679602005825, -70.2005131676838 43.8455720129728, -74.5366825512491 43.6889777784079))
```
