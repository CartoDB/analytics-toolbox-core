### QUADBIN_TOCHILDREN

{{% bannerNote type="code" %}}
carto.QUADBIN_TOCHILDREN(quadbin, resolution)
{{%/ bannerNote %}}

**Description**

Returns an array with the children quadbins of a given quadbin for a specific resolution. A children quadbin is a quadbin of higher level of detail that is contained by the current quadbin. Each quadbin has four children by definition.

* `quadbin`: `INT64` quadbin to get the children from.
* `resolution`: `INT64` resolution of the desired children.

**Return type**

`ARRAY<INT64>`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT `carto-os`.carto.QUADBIN_TOCHILDREN(5209574053332910079, 5);
-- 5214064458820747263
-- 5214073254913769471
-- 5214068856867258367
-- 5214077652960280575
```