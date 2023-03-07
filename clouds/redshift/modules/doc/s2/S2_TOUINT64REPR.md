## S2_TOUINT64REPR

```sql:signature
S2_TOUINT64REPR(id)
```

**Description**

Returns the UINT64 representation of a cell ID.

* `id`: `INT8` S2 cell ID.

**Return type**

`VARCHAR(MAX)`

**Example**

```sql
SELECT carto.S2_TOUINT64REPR(-8520148382826627072);
-- 9926595690882924544
```
