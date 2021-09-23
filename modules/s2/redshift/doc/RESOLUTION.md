### RESOLUTION

{{% bannerNote type="code" %}}
s2.RESOLUTION(id)
{{%/ bannerNote %}}

**Description**

Returns a integer with the resolution of given cell ID.

* `id`: `INT8` id to get the resolution from.

**Return type**

`INT4`

**Example**

```sql
SELECT s2.RESOLUTION('1733885856537640960');
-- 4
```