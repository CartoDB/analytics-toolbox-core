## QUADINT_BOUNDARY

```sql:signature
carto.QUADINT_BOUNDARY(quadint)
```

**Description**

Returns the boundary for a given quadint. We extract the boundary in the same way as when we calculate its [QUADINT_BBOX](#bbox), then enclose it in a GeoJSON and finally transform it into a geography.

* `quadint`: `BIGINT` quadint to get the boundary geography from.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT carto.QUADINT_BOUNDARY(4388);
-- POLYGON((22.5 0, 22.5 -21.9430455334382, 22.67578125 ...
```