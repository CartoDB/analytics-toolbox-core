## QUADBIN_TOPARENT

```sql:signature
QUADBIN_TOPARENT(quadbin, resolution)
```

**Description**

Returns the parent (ancestor) Quadbin of a given Quadbin for a specific resolution. An ancestor of a given Quadbin is a Quadbin of smaller resolution that spatially contains it.

* `quadbin`: `BIGINT` Quadbin to get the parent from.
* `resolution`: `INT` resolution of the desired parent.

**Return type**

`BIGINT`

**Example**

```sql
SELECT carto.QUADBIN_TOPARENT(5207251884775047167, 3);
-- 5202783469519765503
```
