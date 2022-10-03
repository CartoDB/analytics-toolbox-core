### H3_CENTER

{{% bannerNote type="code" %}}
carto.H3_CENTER(index)
{{%/ bannerNote %}}

**Description**

Returns the center of the H3 cell as a GEOGRAPHY point. It will return `null` on error (invalid input).

* `index`: `STRING` The H3 cell index.

**Return type**

`GEOGRAPHY`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT `carto-os`.carto.H3_CENTER('847b59dffffffff');
-- POINT(40.3054764231743 -3.74320332556168)
```
