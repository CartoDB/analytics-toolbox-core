## S2_FROMGEOGPOINT

```sql:signature
S2_FROMGEOGPOINT(point, resolution)
```

**Description**

Returns the S2 cell ID of a given point at a requested resolution.

* `point`: `GEOGRAPHY` vertical coordinate of the map.
* `resolution`: `INT4` level of detail or zoom.

**Return type**

`INT8`

**Example**

```sql
SELECT carto.S2_FROMGEOGPOINT(ST_POINT(-3.7038, 40.4168), 8);
-- 955378847514099712
```
