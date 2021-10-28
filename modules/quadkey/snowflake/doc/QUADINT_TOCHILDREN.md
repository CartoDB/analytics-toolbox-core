### QUADINT_TOCHILDREN

{{% bannerNote type="code" %}}
carto.QUADINT_TOCHILDREN(quadint, resolution)
{{%/ bannerNote %}}

**Description**

Returns an array with the children quadints of a given quadint for a specific resolution. A children quadint is a quadint of higher level of detail that is contained by the current quadint. Each quadint has four children by definition.

* `quadint`: `BIGINT` quadint to get the children from.
* `resolution`: `INT` resolution of the desired children.

**Return type**

`ARRAY`

**Example**

```sql
SELECT carto.QUADINT_TOCHILDREN(1155, 4);
-- 4356
-- 4868
-- 4388
-- 4900
```