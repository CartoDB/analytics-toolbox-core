### QUADINT_TOPARENT

{{% bannerNote type="code" %}}
carto.QUADINT_TOPARENT(quadint, resolution)
{{%/ bannerNote %}}

**Description**

Returns the parent quadint of a given quadint for a specific resolution. A parent quadint is the smaller resolution containing quadint.

* `quadint`: `BIGINT` quadint to get the parent from.
* `resolution`: `INT` resolution of the desired parent.

**Return type**

`BIGINT`

**Example**

```sql
SELECT carto.QUADINT_TOPARENT(4388, 3);
-- 1155
```
