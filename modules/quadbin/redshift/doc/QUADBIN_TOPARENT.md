### QUADBIN_TOPARENT

{{% bannerNote type="code" %}}
carto.QUADBIN_TOPARENT(quadbin, resolution)
{{%/ bannerNote %}}

**Description**

Returns the parent quadbin of a given quadbin for a specific resolution. A parent quadbin is the smaller resolution containing quadbin.

* `quadbin`: `BIGINT` quadbin to get the parent from.
* `resolution`: `INT` resolution of the desired parent.

**Return type**

`BIGINT`

**Example**

```sql
SELECT carto.QUADBIN_TOPARENT(4388, 3);
-- 1155
```