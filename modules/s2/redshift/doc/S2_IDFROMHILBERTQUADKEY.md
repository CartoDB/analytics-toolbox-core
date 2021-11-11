### S2_IDFROMHILBERTQUADKEY

{{% bannerNote type="code" %}}
s2.S2_IDFROMHILBERTQUADKEY(hquadkey)
{{%/ bannerNote %}}

**Description**

Returns the conversion of a Hilbert quadkey (a.k.a Hilbert curve quadtree ID) into a S2 cell ID.

* `hquadkey`: `VARCHAR(MAX)` Hilbert quadkey to be converted.

**Return type**

`INT8`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT s2.S2_IDFROMHILBERTQUADKEY('0/30002221');
-- 1735346007979327488
```