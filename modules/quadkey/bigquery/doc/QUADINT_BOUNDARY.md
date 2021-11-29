### QUADINT_BOUNDARY

{{% bannerNote type="code" %}}
quadkey.QUADINT_BOUNDARY(quadint)
{{%/ bannerNote %}}

**Description**

Returns the boundary for a given quadint. We extract the boundary in the same way as when we calculate its [QUADINT_BBOX](#quadint_bbox), then enclose it in a GeoJSON and finally transform it into a geography.

* `quadint`: `INT64` quadint to get the boundary geography from.

**Return type**

`GEOGRAPHY`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto-os.quadkey.QUADINT_BOUNDARY(4388);
-- POLYGON((22.5 0, 22.5 -21.9430455334382, 22.67578125 ...
```