### ST_ASQUADINT

{{% bannerNote type="code" %}}
quadkey.ST_ASQUADINT(point, resolution)
{{%/ bannerNote %}}

**Description**

Returns the quadint of a given point at a given level of detail.

* `point`: `GEOGRAPHY` point to get the quadint from.
* `resolution`: `INT` level of detail or zoom.

**Return type**

`BIGINT`

**Example**

```sql
SELECT sfcarto.quadkey.ST_ASQUADINT(ST_POINT(40.4168, -3.7038), 4);
-- 4388
```