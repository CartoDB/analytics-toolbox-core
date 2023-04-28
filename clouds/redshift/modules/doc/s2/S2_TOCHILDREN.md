## S2_TOCHILDREN

```sql:signature
S2_TOCHILDREN(id [, resolution])
```

**Description**

Returns a SUPER containing a plain array of children IDs of a given cell ID for a specific resolution.
A child is an S2 cell of higher level of detail that is contained within the current cell. Each cell has four direct children by definition.

By default, this function returns the direct children (where parent resolution is children resolution - 1). However, an optional resolution argument can be passed with the desired parent resolution. Note that the amount of children grows to the power of four per zoom level.

* `id`: `INT8` id to get the children from.
* `resolution` (optional): `INT4` resolution of the desired children.

**Return type**

`SUPER`

**Example**

```sql
SELECT carto.S2_TOCHILDREN(955378847514099712);
-- 955365653374566400
-- 955374449467588608
-- 955383245560610816
-- 955392041653633024

SELECT carto.S2_TOCHILDREN(955378847514099712, 9);
-- 955365653374566400
-- 955374449467588608
-- 955383245560610816
-- 955392041653633024
```
