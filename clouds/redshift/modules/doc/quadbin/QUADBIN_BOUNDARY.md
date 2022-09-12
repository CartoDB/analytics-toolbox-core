### QUADBIN_BOUNDARY

{{% bannerNote type="code" %}}
carto.QUADBIN_BOUNDARY(quadbin)
{{%/ bannerNote %}}

**Description**

Returns the boundary for a given quadbin. We extract the boundary in the same way as when we calculate its [QUADBIN_BBOX](#quadbin_bbox), then enclose it in a GeoJSON and finally transform it into a geography.

* `quadbin`: `BIGINT` quadbin to get the boundary geography from.

**Return type**

`GEOMETRY`

**Example**

```sql
SELECT carto.QUADBIN_BOUNDARY(5209574053332910079);
-- POLYGON ((22.5 -21.9430455334, 22.5 0, 45 0, 45 -21.9430455334, 22.5 -21.9430455334))
```
