## S2_TOTOKEN

```sql:signature
S2_TOTOKEN(id)
```

**Description**

Returns the conversion of a S2 cell ID into a token (S2 cell hexified ID).

* `id`: `INT64` S2 cell ID.

**Return type**

`STRING`

**Example**

```sql
SELECT carto.S2_TOTOKEN(955378847514099712);
-- 0d42300000000000
```
