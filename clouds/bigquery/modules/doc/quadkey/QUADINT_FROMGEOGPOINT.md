## QUADINT_FROMGEOGPOINT

```sql:signature
carto.QUADINT_FROMGEOGPOINT(point, resolution)
```

**Description**

Returns the quadint of a given point at a given level of detail.

* `point`: `GEOGRAPHY` point to get the quadint from.
* `resolution`: `INT64` level of detail or zoom.

**Return type**

`INT64`


**Example**


```sql
SELECT `carto-os`.carto.QUADINT_FROMGEOGPOINT(ST_GEOGPOINT(40.4168, -3.7038), 4);
-- 4388
```