### QUADBIN_FROMGEOGPOINT

{{% bannerNote type="code" %}}
carto.QUADBIN_FROMGEOGPOINT(point, resolution)
{{%/ bannerNote %}}

**Description**

Returns the quadbin of a given point at a given level of detail.

* `point`: `GEOGRAPHY` point to get the quadbin from.
* `resolution`: `INT64` level of detail or zoom.

**Return type**

`INT64`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT `carto-os`.carto.QUADBIN_FROMGEOGPOINT(ST_GEOGPOINT(40.4168, -3.7038), 4);
-- 5209574053332910079
```