### TOCHILDREN

{{% bannerNote type="code" %}}
quadkey.TOCHILDREN(quadint, resolution)
{{%/ bannerNote %}}

**Description**

Returns an array with the children quadints of a given quadint for a specific resolution. A children quadint is a quadint of higher level of detail that is contained by the current quadint. Each quadint has four children by definition.

* `quadint`: `INT64` quadint to get the children from.
* `resolution`: `INT64` resolution of the desired children.

**Return type**

`ARRAY<INT64>`

**Example**

```sql
SELECT bqcarto.quadkey.TOCHILDREN(1155, 4);
-- 4356
-- 4868
-- 4388
-- 4900
```
