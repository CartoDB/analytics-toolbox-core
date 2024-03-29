## QUADBIN_BBOX

```sql:signature
QUADBIN_BBOX(quadbin)
```

**Description**

Returns an array with the boundary box of a given Quadbin. This boundary box contains the minimum and maximum longitude and latitude. The output format is [West-South, East-North] or [min long, min lat, max long, max lat].

* `quadbin`: `INT64` Quadbin to get the bbox from.

**Return type**

`ARRAY<FLOAT64>`

**Example**

```sql
SELECT carto.QUADBIN_BBOX(5207251884775047167);
-- -22.5
-- 21.943045533438188
-- 0.0
-- 40.979898069620127
```
