## PLACEKEY_FROMH3

```sql:signature
PLACEKEY_FROMH3(h3index)
```

**Description**

Returns the placekey equivalent to the given H3 index.

* `h3index`: `STRING` H3 identifier.

**Return type**

`STRING`

**Example**

```sql
SELECT carto.PLACEKEY_FROMH3('84390cbffffffff');
-- @7dd-dc3-52k
```
