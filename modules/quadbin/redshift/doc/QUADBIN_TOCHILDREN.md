### QUADBIN_TOCHILDREN

{{% bannerNote type="code" %}}
carto.QUADBIN_TOCHILDREN(quadbin, resolution)
{{%/ bannerNote %}}

**Description**

Returns an array with the children quadbins of a given quadbin for a specific resolution. A children quadbin is a quadbin of higher level of detail that is contained within the current quadbin. Each quadbin has four children by definition.

* `quadbin`: `BIGINT` quadbin to get the children from.
* `resolution`: `INT` resolution of the desired children.

**Return type**

`ARRAY`

**Example**

```sql
SELECT carto.QUADBIN_TOCHILDREN(1155, 4);
-- 4356
-- 4868
-- 4388
-- 4900
```