## S2_TOTOKEN

```sql:signature
carto.S2_TOTOKEN(id)
```

**Description**

Returns the conversion of a S2 cell ID into a token (S2 cell hexified ID).

* `id`: `INT8` S2 cell ID.

**Return type**

`VARCHAR(MAX)`

**Example**

```sql
SELECT carto.S2_TOTOKEN(-8520148382826627072);
-- 89c25a3
```
