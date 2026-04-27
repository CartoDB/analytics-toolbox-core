## QUADBIN_RESOLUTION

```sql:signature
QUADBIN_RESOLUTION(quadbin)
```

**Description**

Returns the resolution of the input Quadbin.

**Input parameters**

* `quadbin`: `NUMBER` Quadbin from which to get the resolution.

**Return type**

`NUMBER`

**Example**

```sql
SELECT carto.QUADBIN_RESOLUTION(5207251884775047167) FROM DUAL;
-- 4
```
