## S2_TOUINT64REPR

```sql:signature
carto.S2_TOUINT64REPR(id)
```

**Description**

Returns the UINT64 representation of a cell ID.

* `id`: `INT64` S2 cell ID.

**Return type**

`STRING`

**Example**

```sql
SELECT carto.S2_TOUINT64REPR(-8520148382826627072);
-- 9926595690882924544
```
