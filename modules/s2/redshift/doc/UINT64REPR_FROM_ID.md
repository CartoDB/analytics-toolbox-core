### UINT64REPR_FROM_ID

{{% bannerNote type="code" %}}
s2.UINT64REPR_FROM_ID(id)
{{%/ bannerNote %}}

**Description**

Returns the UINT64 representation of a cell ID.

* `id`: `INT8` S2 cell ID.

**Return type**

`VARCHAR`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT s2.UINT64REPR_FROM_ID(-8520148382826627072);
-- 9926595690882924544
```
