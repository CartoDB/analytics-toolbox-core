### S2_IDFROMUINT64REPR

{{% bannerNote type="code" %}}
carto.S2_IDFROMUINT64REPR(uid)
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
SELECT carto-os.carto.S2_IDFROMUINT64REPR('9926595690882924544');
-- -8520148382826627072
```