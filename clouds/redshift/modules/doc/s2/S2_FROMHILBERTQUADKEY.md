## S2_FROMHILBERTQUADKEY

```sql:signature
carto.S2_FROMHILBERTQUADKEY(hquadkey)
```

**Description**

Returns the conversion of a Hilbert quadkey (a.k.a Hilbert curve quadtree ID) into a S2 cell ID.

* `hquadkey`: `VARCHAR(MAX)` Hilbert quadkey to be converted.

**Return type**

`INT8`

**Example**

```sql
SELECT carto.S2_FROMHILBERTQUADKEY('0/30002221');
-- 1735346007979327488
```
