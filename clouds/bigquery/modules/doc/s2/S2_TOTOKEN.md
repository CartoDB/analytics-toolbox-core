## S2_TOTOKEN

```sql:signature
carto.S2_TOTOKEN(id)
```

**Description**

Returns the conversion of a S2 cell ID into a token (S2 cell hexified ID).

* `id`: `INT64` S2 cell ID.

**Return type**

`STRING`


**Example**


```sql
SELECT `carto-os`.carto.S2_TOTOKEN(-8520148382826627072);
-- 89c25a3000000000
```