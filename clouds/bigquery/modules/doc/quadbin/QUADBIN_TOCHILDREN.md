## QUADBIN_TOCHILDREN

```sql:signature
carto.QUADBIN_TOCHILDREN(quadbin, resolution)
```

**Description**

Returns an array with the children Quadbins of a given Quadbin for a specific resolution. A children Quadbin is a Quadbin of higher level of detail that is contained by the current Quadbin. Each Quadbin has four direct children (at the next higher resolution).

* `quadbin`: `INT64` Quadbin to get the children from.
* `resolution`: `INT64` resolution of the desired children.

**Return type**

`ARRAY<INT64>`


**Example**


```sql
SELECT `carto-os`.carto.QUADBIN_TOCHILDREN(5209574053332910079, 5);
-- 5214064458820747263
-- 5214073254913769471
-- 5214068856867258367
-- 5214077652960280575
```