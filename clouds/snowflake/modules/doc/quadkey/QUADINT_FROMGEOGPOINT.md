### QUADINT_FROMGEOGPOINT

{{% bannerNote type="code" %}}
carto.QUADINT_FROMGEOGPOINT(point, resolution)
{{%/ bannerNote %}}

**Description**

Returns the quadint of a given point at a given level of detail.

* `point`: `GEOGRAPHY` point to get the quadint from.
* `resolution`: `INT` level of detail or zoom.

**Return type**

`BIGINT`

**Example**

```sql
SELECT carto.QUADINT_FROMGEOGPOINT(ST_POINT(40.4168, -3.7038), 4);
-- 4388
```