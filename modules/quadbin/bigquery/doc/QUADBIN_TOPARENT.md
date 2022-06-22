### QUADBIN_TOPARENT

{{% bannerNote type="code" %}}
carto.QUADBIN_TOPARENT(quadbin, resolution)
{{%/ bannerNote %}}

**Description**

Returns the parent quadbin of a given quadbin for a specific resolution. A parent quadbin is the smaller resolution containing quadbin.

* `quadbin`: `INT64` quadbin to get the parent from.
* `resolution`: `INT64` resolution of the desired parent.

**Return type**

`INT64`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT `carto-os`.carto.QUADBIN_TOPARENT(5209574053332910079, 3);
-- 5205105638077628415
```