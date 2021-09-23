### ST_ASID

{{% bannerNote type="code" %}}
s2.ST_ASID(point, resolution)
{{%/ bannerNote %}}

**Description**

Returns the S2 cell ID of a given point at a given level of detail.

* `point`: `GEOGRAPHY` vertical coordinate of the map.
* `resolution`: `INT4` level of detail or zoom.

**Return type**

`INT8`

**Example**

```sql
SELECT s2.ST_ASID(ST_Point(40.4168, -3.7038), 4);
-- 1733885856537640960
```