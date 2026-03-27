## S2_FROMTOKEN

```sql:signature
S2_FROMTOKEN(token)
```

**Description**

Returns the conversion of a token into a S2 cell ID.

**Input parameters**

* `token`: `STRING` S2 cell hexified ID.

**Return type**

`INT64`

**Example**

```sql
SELECT carto.S2_FROMTOKEN('0d423');
-- 955378847514099712
```
