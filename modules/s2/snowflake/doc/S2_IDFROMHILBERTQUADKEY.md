### S2_IDFROMHILBERTQUADKEY

{{% bannerNote type="code" %}}
s2.S2_IDFROMHILBERTQUADKEY(hquadkey)
{{%/ bannerNote %}}

**Description**

Returns the conversion of a Hilbert quadkey (a.k.a Hilbert curve quadtree ID) into a S2 cell ID.

* `hquadkey`: `STRING` Hilbert quadkey to be converted.

**Return type**

`BIGINT`

**Example**

```sql
SELECT sfcarto.s2.S2_IDFROMHILBERTQUADKEY('0/30002221');
-- 1735346007979327488
```