### ID_FROMUINT64REPR

{{% bannerNote type="code" %}}
s2.ID_FROMUINT64REPR(uint64_id)
{{%/ bannerNote %}}

**Description**

Returns an INT64 cell ID from its UINT64 representation.

* `uint64_id`: `VARCHAR` S2 INT64 cell ID.

**Return type**

`INT8`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT s2.ID_FROMUINT64REPR('9926595690882924544');
-- -8520148382826627072
```
