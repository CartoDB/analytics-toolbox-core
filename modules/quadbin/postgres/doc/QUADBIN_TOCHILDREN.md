### QUADBIN_TOCHILDREN

{{% bannerNote type="code" %}}
carto.QUADBIN_TOCHILDREN(quadbin, resolution)
{{%/ bannerNote %}}

**Description**

Returns an array with the children quadbins of a given quadbin for a specific resolution. A children quadbin is a quadbin of higher level of detail that is contained by the current quadbin. Each quadbin has four children by definition.

* `quadbin`: `BIGINT` quadbin to get the children from.
* `resolution`: `INT` resolution of the desired children.

**Return type**

`BIGINT[]`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto.QUADBIN_TOCHILDREN(5209574053332910079, 5);
-- { 5214064458820747263,
--   5214073254913769471,
--   5214068856867258367,
--   5214077652960280575 }
```