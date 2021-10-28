### S2_IDFROMGEOGPOINT

{{% bannerNote type="code" %}}
s2.S2_IDFROMGEOGPOINT(point, resolution)
{{%/ bannerNote %}}

**Description**

Returns the S2 cell ID of a given point at a given level of detail.

* `point`: `GEOGRAPHY` point to get the ID from.
* `resolution`: `INT` level of detail or zoom.

**Return type**

`BIGINT`

**Example**

```sql
SELECT sfcarto.s2.S2_IDFROMGEOGPOINT(ST_POINT(40.4168, -3.7038), 8);
-- 1735346007979327488
```