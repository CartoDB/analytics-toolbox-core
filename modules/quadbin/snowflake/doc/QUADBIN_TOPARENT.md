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

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto.QUADBIN_TOPARENT(5209574053332910079, 3);
-- 5205105638077628415
```