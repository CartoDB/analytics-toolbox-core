### ID_FROMUINT64REPR

{{% bannerNote type="code" %}}
s2.ID_FROMUINT64REPR(uid)
{{%/ bannerNote %}}

**Description**

Returns the cell ID from a UINT64 representation.

* `uid`: `STRING` UINT64 representation of a S2 cell ID.

**Return type**

`INT64`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto-os.s2.ID_FROMUINT64REPR('9926595690882924544');
-- -8520148382826627072
```