### S2_TOHILBERTQUADKEY

{{% bannerNote type="code" %}}
carto.S2_TOHILBERTQUADKEY(id)
{{%/ bannerNote %}}

**Description**

Returns the conversion of a S2 cell ID into a Hilbert quadkey (a.k.a Hilbert curve quadtree ID).

* `id`: `INT8` S2 cell ID to be converted.

**Return type**

`VARCHAR(MAX)`

**Example**

```sql
SELECT carto.S2_TOHILBERTQUADKEY(1735346007979327488);
-- 0/30002221
```