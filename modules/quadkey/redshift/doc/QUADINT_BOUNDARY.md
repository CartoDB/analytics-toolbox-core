### QUADINT_BOUNDARY

{{% bannerNote type="code" %}}
carto.QUADINT_BOUNDARY(quadint)
{{%/ bannerNote %}}

**Description**

Returns the boundary for a given quadint. We extract the boundary in the same way as when we calculate its [QUADINT_BBOX](#bbox), then enclose it in a GeoJSON and finally transform it into a geography.

* `quadint`: `BIGINT` quadint to get the boundary geography from.

**Return type**

`GEOMETRY`

**Example**

```sql
SELECT carto.QUADINT_BOUNDARY(4388);
-- {'type': 'Polygon', 'coordinates': [[[22.5, -21.943045533438177], [22.5, 0.0], ...
```