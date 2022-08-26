### S2_FROMUINT64REPR

{{% bannerNote type="code" %}}
carto.S2_FROMUINT64REPR(uid)
{{%/ bannerNote %}}

**Description**

Returns an INT64 cell ID from its UINT64 representation.

* `uid`: `VARCHAR(MAX)` UINT64 representation of a S2 cell ID.

**Return type**

`INT8`

**Example**

```sql
SELECT carto.S2_FROMUINT64REPR('9926595690882924544');
-- -8520148382826627072
```