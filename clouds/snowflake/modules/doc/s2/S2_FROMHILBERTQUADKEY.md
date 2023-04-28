## S2_FROMHILBERTQUADKEY

```sql:signature
S2_FROMHILBERTQUADKEY(hquadkey)
```

**Description**

Returns the conversion of a Hilbert quadkey (a.k.a Hilbert curve quadtree ID) into a S2 cell ID.

* `hquadkey`: `STRING` Hilbert quadkey to be converted.

**Return type**

`BIGINT`

**Example**

```sql
SELECT carto.S2_FROMHILBERTQUADKEY('0/12220101');
-- 955378847514099712
```
