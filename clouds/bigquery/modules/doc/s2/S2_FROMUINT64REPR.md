## S2_FROMUINT64REPR

```sql:signature
S2_FROMUINT64REPR(uid)
```

**Description**

Returns the cell ID from a UINT64 representation.

* `uid`: `STRING` UINT64 representation of a S2 cell ID.

**Return type**

`INT64`

**Example**

```sql
SELECT carto.S2_FROMUINT64REPR('9926595690882924544');
-- -8520148382826627072
```
