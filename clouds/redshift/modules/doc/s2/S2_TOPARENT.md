## S2_TOPARENT

```sql:signature
carto.S2_TOPARENT(id, resolution)
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
SELECT carto.S2_TOPARENT(1733885856537640960);
-- 1747396655419752448

SELECT carto.S2_TOPARENT(1733885856537640960, 1);
-- 2017612633061982208
```