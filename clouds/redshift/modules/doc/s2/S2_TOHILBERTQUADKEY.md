## S2_TOHILBERTQUADKEY

```sql:signature
S2_TOHILBERTQUADKEY(id)
```

**Description**

Returns the conversion of a S2 cell ID into a Hilbert quadkey (a.k.a Hilbert curve quadtree ID).

* `id`: `INT8` S2 cell ID to be converted.

**Return type**

`VARCHAR(MAX)`

**Example**

```sql
SELECT carto.S2_TOHILBERTQUADKEY(955378847514099712);
-- 0/12220101
```
