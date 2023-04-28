## S2_CENTER

```sql:signature
S2_CENTER(id)
```

**Description**

Returns a POINT corresponding to the centroid of an S2 cell, given its ID.

* `id`: `INT64` S2 cell ID to get the boundary geography from.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT carto.S2_CENTER(955378847514099712);
-- POINT(-3.58126923539589 40.4167087628243)
```
