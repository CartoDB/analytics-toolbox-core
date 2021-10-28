### S2_HILBERTQUADKEYFROMCELLID

{{% bannerNote type="code" %}}
s2.S2_HILBERTQUADKEYFROMCELLID(id)
{{%/ bannerNote %}}

**Description**

Returns the conversion of a S2 cell ID into a Hilbert quadkey (a.k.a Hilbert curve quadtree ID).

* `id`: `BIGINT` S2 cell ID to be converted.

**Return type**

`STRING`

**Example**

```sql
SELECT sfcarto.s2.S2_HILBERTQUADKEYFROMCELLID(1735346007979327488);
-- 0/30002221
```