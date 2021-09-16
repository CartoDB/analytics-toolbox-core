### TOCHILDREN

{{% bannerNote type="code" %}}
s2.GET_RESOLUTION(id)
{{%/ bannerNote %}}

**Description**

Returns a INTEGER with the resolution of given cell ID. S2 defines cells from a minimum resolution of 

* `id`: `VARCHAR` id to get the resolution from.

**Return type**

`INTEGER`

**Example**

```sql
SELECT s2.GET_RESOLUTION('1733885856537640960');
-- 4
```