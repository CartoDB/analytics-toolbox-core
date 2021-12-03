### S2_TOUINT64REPR

{{% bannerNote type="code" %}}
carto.S2_TOUINT64REPR(id)
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
SELECT carto-os.carto.S2_TOUINT64REPR(-8520148382826627072);
-- 9926595690882924544
```
