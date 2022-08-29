### QUADBIN_FROMGEOGPOINT

{{% bannerNote type="code" %}}
carto.QUADBIN_FROMGEOGPOINT(point, resolution)
{{%/ bannerNote %}}

**Description**

Returns the quadbin of a given point at a given level of detail.

* `point`: `GEOMETRY` point to get the quadbin from.
* `resolution`: `INT` level of detail or zoom.

**Return type**

`BIGINT`

**Example**

```sql
SELECT carto.QUADBIN_FROMGEOGPOINT(ST_POINT(40.4168, -3.7038), 4);
-- 5209574053332910079
```