## S2_TOPARENT

```sql:signature
S2_TOPARENT(id, resolution)
```

**Description**

Returns the parent ID of a given cell ID for a specific resolution. A parent cell is the smaller resolution containing cell.

By default, this function returns the direct parent (where parent resolution is child resolution + 1). However, an optional resolution argument can be passed with the desired parent resolution.

* `id`: `INT8` quadint to get the parent from.
* `resolution` (optional): `INT4` resolution of the desired parent.

**Return type**

`INT8`

**Example**

```sql
SELECT carto.S2_TOPARENT(955378847514099712);
-- 955396439700144128

SELECT carto.S2_TOPARENT(955378847514099712, 1);
-- 864691128455135232
```
