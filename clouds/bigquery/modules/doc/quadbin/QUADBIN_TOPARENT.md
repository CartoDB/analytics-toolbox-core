## QUADBIN_TOPARENT

```sql:signature
carto.QUADBIN_TOPARENT(quadbin, resolution)
```

**Description**

Returns the parent (ancestor) Quadbin of a given Quadbin for a specific resolution. An ancestor of a given Quadbin is a Quadbin of smaller resolution that spatially contains it.

* `quadbin`: `INT64` Quadbin to get the parent from.
* `resolution`: `INT64` resolution of the desired parent.

**Return type**

`INT64`

**Example**

```sql
SELECT carto.QUADBIN_TOPARENT(5209574053332910079, 3);
-- 5205105638077628415
```
