## PLACEKEY_ISVALID

```sql:signature
PLACEKEY_ISVALID(placekey)
```

**Description**

Returns a boolean value `true` when the given string represents a valid Placekey, `false` otherwise.

* `placekey`: `STRING` Placekey identifier.

**Return type**

`BOOLEAN`

**Examples**

```sql
SELECT carto.PLACEKEY_ISVALID('@7dd-dc3-52k');
-- true
```

```sql
SELECT carto.PLACEKEY_ISVALID('7dd-dc3-52k');
-- true
```

```sql
SELECT carto.PLACEKEY_ISVALID('x');
-- false
```
