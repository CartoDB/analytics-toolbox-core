### TOPARENT

{{% bannerNote type="code" %}}
quadkey.TOPARENT(quadint, resolution)
{{%/ bannerNote %}}

**Description**

Returns the parent quadint of a given quadint for a specific resolution. A parent quadint is the smaller resolution containing quadint.

* `quadint`: `INT64` quadint to get the parent from.
* `resolution`: `INT64` resolution of the desired parent.

**Return type**

`INT64`

**Example**

```sql
SELECT bqcarto.quadkey.TOPARENT(4388, 3);
-- 1155
```
