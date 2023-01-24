## PLACEKEY_ASH3

```sql:signature
carto.PLACEKEY_ASH3(placekey)
```

**Description**

Returns the H3 index equivalent to the given placekey.

* `placekey`: `VARCHAR` Placekey identifier.

**Return type**

`VARCHAR`

**Example**

```sql
SELECT carto.PLACEKEY_ASH3('@ff7-swh-m49');
-- 8a7b59dffffffff
```
