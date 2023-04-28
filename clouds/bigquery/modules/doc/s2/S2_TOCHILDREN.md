## S2_TOCHILDREN

```sql:signature
S2_TOCHILDREN(index, resolution)
```

**Description**

Returns an array with the S2 indexes of the children/descendents of the given hexagon at the given resolution.

* `index`: `STRING` The S2 cell index.
* `resolution`: `INT64` number between 0 and 30 with the [S2 resolution](https://S2geo.org/docs/core-library/restable).

**Return type**

`ARRAY<STRING>`

**Example**

```sql
SELECT carto.S2_TOCHILDREN(955378847514099712, 10);
-- 955365653374566400
-- 955374449467588608
-- 955383245560610816
-- 955392041653633024
```
