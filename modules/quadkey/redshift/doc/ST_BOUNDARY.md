### ST_BOUNDARY

{{% bannerNote type="code" %}}
quadkey.ST_BOUNDARY(quadint)
{{%/ bannerNote %}}

**Description**

Returns the boundary for a given quadint. We extract the boundary in the same way as when we calculate its [BBOX](#bbox), then enclose it in a GeoJSON and finally transform it into a geography.

* `quadint`: `BIGINT` quadint to get the boundary geography from.

**Return type**

`GEOMETRY`

**Example**

```sql
SELECT quadkey.ST_BOUNDARY(4388);
-- {'type': 'Polygon', 'coordinates': [[[22.5, -21.943045533438177], [22.5, 0.0], ...
```