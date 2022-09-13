### S2_FROMHILBERTQUADKEY

{{% bannerNote type="code" %}}
carto.S2_FROMHILBERTQUADKEY(hquadkey)
{{%/ bannerNote %}}

**Description**

Returns the conversion of a Hilbert quadkey (a.k.a Hilbert curve quadtree ID) into a S2 cell ID.

* `hquadkey`: `STRING` Hilbert quadkey to be converted.

**Return type**

`INT64`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT `carto-os`.carto.S2_FROMHILBERTQUADKEY('0/30002221');
-- 1735346007979327488
```
