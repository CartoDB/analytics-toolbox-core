## PLACEKEY_TOH3

```sql:signature
carto.PLACEKEY_TOH3(placekey)
```

**Description**

Returns the H3 index equivalent of the given placekey.

* `placekey`: `STRING` Placekey identifier.

**Return type**

`STRING`

**Example**

```sql
SELECT carto.PLACEKEY_TOH3('@ff7-swh-m49');
-- 8a7b59dffffffff
```
