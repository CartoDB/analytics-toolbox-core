### S2_HILBERTQUADKEYFROMID

{{% bannerNote type="code" %}}
carto.S2_HILBERTQUADKEYFROMID(id)
{{%/ bannerNote %}}

**Description**

Returns the conversion of a S2 cell ID into a Hilbert quadkey (a.k.a Hilbert curve quadtree ID).

* `id`: `INT8` S2 cell ID to be converted.

**Return type**

`VARCHAR(MAX)`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto.S2_HILBERTQUADKEYFROMID(1735346007979327488);
-- 0/30002221
```