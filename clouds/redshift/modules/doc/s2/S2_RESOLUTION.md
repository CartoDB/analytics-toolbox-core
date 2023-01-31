## S2_RESOLUTION

```sql:signature
carto.S2_RESOLUTION(id)
```

**Description**

Returns an integer with the resolution of a given cell ID.

* `id`: `INT8` id to get the resolution from.

**Return type**

`INT4`

**Example**

```sql
SELECT carto.S2_RESOLUTION('1733885856537640960');
-- 4
```
