### S2_UINT64REPRFROMID

{{% bannerNote type="code" %}}
carto.S2_UINT64REPRFROMID(id)
{{%/ bannerNote %}}

**Description**

Returns the UINT64 representation of a cell ID.

* `id`: `INT64` S2 cell ID.

**Return type**

`STRING`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto-os.carto.S2_UINT64REPRFROMID(-8520148382826627072);
-- 9926595690882924544
```
