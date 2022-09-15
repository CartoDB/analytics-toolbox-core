### S2_CENTER

{{% bannerNote type="code" %}}
carto.S2_CENTER(id)
{{%/ bannerNote %}}

**Description**

Returns a POINT corresponding to the centroid of an S2 cell, given its ID.

* `id`: `INT64` S2 cell ID to get the boundary geography from.

**Return type**

`GEOGRAPHY`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT `carto-os`.carto.S2_CENTER(1735346007979327488);
-- POINT(40.4720004343497 -3.72646193231851)
```