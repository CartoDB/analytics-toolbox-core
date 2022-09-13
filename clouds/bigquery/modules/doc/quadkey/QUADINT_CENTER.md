### QUADINT_CENTER

{{% bannerNote type="code" %}}
carto.QUADINT_CENTER(quadint)
{{%/ bannerNote %}}

**Description**

Returns the center for a given quadint. The center is defined as the intersection point of the four immediate children quadint. 

* `quadint`: `INT64` quadint to get the center from.

**Return type**

`GEOGRAPHY`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT `carto-os`.carto.QUADINT_CENTER(4388);
-- POINT(33.75 -11.1784018737118)
```