## QUADBIN_RESOLUTION

```sql:signature
carto.QUADBIN_RESOLUTION(quadbin)
```

**Description**

Returns the resolution of the input Quadbin.

* `quadbin`: `INT64` Quadbin from which to get the resolution.

**Return type**

`INT64`


**Example**


```sql
SELECT `carto-os`.carto.QUADBIN_RESOLUTION(5209574053332910079);
-- 4
```