### H3_BOUNDARY

{{% bannerNote type="code" %}}
carto.H3_BOUNDARY(index)
{{%/ bannerNote %}}

**Description**

Returns a geography representing the H3 cell. It will return `null` on error (invalid input).

* `index`: `STRING` The H3 cell index as hexadecimal.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT carto.H3_BOUNDARY('847b59dffffffff');
-- { "coordinates": [ [ [ 40.46506362234518, -3.9352772457964957 ], [ 40.546540602670504, -3.706115055436962 ], ...
```