## QUADBIN_RESOLUTION

```sql:signature
QUADBIN_RESOLUTION(quadbin)
```

**Description**

Returns the resolution of the input Quadbin.

* `quadbin`: `INT64` Quadbin from which to get the resolution.

**Return type**

`INT64`

**Example**

```sql
SELECT carto.QUADBIN_RESOLUTION(5207251884775047167);
-- 4
```
