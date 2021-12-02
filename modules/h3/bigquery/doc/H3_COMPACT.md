### H3_COMPACT

{{% bannerNote type="code" %}}
carto.H3_COMPACT(indexArray)
{{%/ bannerNote %}}

**Description**

Returns an array with the indexes of a set of hexagons across multiple resolutions that represent the same area as the input set of hexagons.

* `indexArray`: `ARRAY<STRING>` of H3 cell indices of the same resolution.

**Return type**

`ARRAY<STRING>`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto-os.carto.H3_COMPACT(['857b59c3fffffff', '857b59c7fffffff', '857b59cbfffffff', '857b59cffffffff', '857b59d3fffffff', '857b59d7fffffff', '857b59dbfffffff']);
-- 847b59dffffffff
```