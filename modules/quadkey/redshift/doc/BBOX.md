### BBOX

{{% bannerNote type="code" %}}
quadkey.BBOX(quadint)
{{%/ bannerNote %}}

**Description**

Returns an array with the boundary box of a given quadint. This boundary box contains the minimum and maximum longitude and latitude. The output format is [West-South, East-North] or [min long, min lat, max long, max lat].

* `quadint`: `BIGINT` quadint to get the bbox from.

**Return type**

`SUPER`

**Example**

```sql
SELECT quadkey.BBOX(4388);
-- 22.5
-- -21.9430455334
-- 45.0
-- 0.0
```