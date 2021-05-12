### HILBERTQUADKEY_FROMID

{{% bannerNote type="code" %}}
s2.HILBERTQUADKEY_FROMID(id)
{{%/ bannerNote %}}

**Description**

Returns the conversion of a S2 cell ID into a Hilbert quadkey (a.k.a Hilbert curve quadtree ID).

* `id`: `BIGNUMERIC` S2 cell ID to be converted.

**Return type**

`STRING`

**Example**

```sql
SELECT bqcarto.s2.HILBERTQUADKEY_FROMID(1735346007979327488);
-- 0/30002221
```