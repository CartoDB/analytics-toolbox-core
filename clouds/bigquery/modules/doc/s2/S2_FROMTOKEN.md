## S2_FROMTOKEN

```sql:signature
carto.S2_FROMTOKEN(token)
```

**Description**

Returns the conversion of a token into a S2 cell ID.

* `token`: `STRING` S2 cell hexified ID.

**Return type**

`INT64`

**Example**

```sql
SELECT `carto-os`.carto.S2_FROMTOKEN('89c25a3000000000');
-- -8520148382826627072
```
