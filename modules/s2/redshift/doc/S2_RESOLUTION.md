### S2_RESOLUTION

{{% bannerNote type="code" %}}
carto.S2_RESOLUTION(id)
{{%/ bannerNote %}}

**Description**

Returns a integer with the resolution of given cell ID.

* `id`: `INT8` id to get the resolution from.

**Return type**

`INT4`

**Example**

```sql
SELECT carto.S2_RESOLUTION('1733885856537640960');
-- 4
```