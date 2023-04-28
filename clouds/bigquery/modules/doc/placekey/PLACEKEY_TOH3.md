## PLACEKEY_TOH3

```sql:signature
PLACEKEY_TOH3(placekey)
```

**Description**

Returns the H3 index equivalent of the given placekey.

* `placekey`: `STRING` Placekey identifier.

**Return type**

`STRING`

**Example**

```sql
SELECT carto.PLACEKEY_TOH3('@7dd-dc3-52k');
-- 8a390cbffffffff
```
