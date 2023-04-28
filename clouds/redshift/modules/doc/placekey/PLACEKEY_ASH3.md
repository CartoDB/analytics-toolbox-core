## PLACEKEY_ASH3

```sql:signature
PLACEKEY_ASH3(placekey)
```

**Description**

Returns the H3 index equivalent to the given placekey.

* `placekey`: `VARCHAR` Placekey identifier.

**Return type**

`VARCHAR`

**Example**

```sql
SELECT carto.PLACEKEY_ASH3('@7dd-dc3-52k');
-- 8a390cbffffffff
```
