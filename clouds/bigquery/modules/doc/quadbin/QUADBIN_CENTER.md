### QUADBIN_CENTER

{{% bannerNote type="code" %}}
carto.QUADBIN_CENTER(quadbin)
{{%/ bannerNote %}}

**Description**

Returns the center for a given quadbin. The center is defined as the intersection point of the four immediate children quadbin.

* `quadbin`: `INT64` quadbin to get the center from.

**Return type**

`GEOGRAPHY`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT `carto-os`.carto.QUADBIN_CENTER(5209574053332910079);
-- POINT(33.75 -11.1784018737118)
```