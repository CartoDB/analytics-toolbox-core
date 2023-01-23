## QUADINT_RESOLUTION

```sql:signature
carto.QUADINT_RESOLUTION(quadint)
```

**Description**

Returns the resolution of the input quadint.

* `quadint`: `INT64` quadint from which to get resolution.

**Return type**

`INT64`

**Example**

```sql
SELECT `carto-os`.carto.QUADINT_RESOLUTION(4388);
-- 4
```
