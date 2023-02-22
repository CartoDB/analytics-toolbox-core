## S2_FROMGEOGPOINT

```sql:signature
carto.S2_FROMGEOGPOINT(point, resolution)
```

**Description**

Returns the S2 cell ID of a given point at a given level of detail.

* `point`: `GEOGRAPHY` point to get the ID from.
* `resolution`: `INT64` level of detail or zoom.

**Return type**

`INT64`

**Example**

```sql
SELECT carto.S2_FROMGEOGPOINT(ST_GEOGPOINT(40.4168, -3.7038), 8);
-- 1735346007979327488
```
