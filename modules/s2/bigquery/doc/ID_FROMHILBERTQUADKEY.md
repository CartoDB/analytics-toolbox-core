### ID_FROMHILBERTQUADKEY

{{% bannerNote type="code" %}}
s2.ID_FROMHILBERTQUADKEY(hquadkey)
{{%/ bannerNote %}}

**Description**

Returns the conversion of a Hilbert quadkey (a.k.a Hilbert curve quadtree ID) into a S2 cell ID.

* `hquadkey`: `STRING` Hilbert quadkey to be converted.

**Return type**

`BIGNUMERIC`

**Example**

```sql
SELECT bqcarto.s2.ID_FROMHILBERTQUADKEY('0/30002221');
-- 1735346007979327488
```
