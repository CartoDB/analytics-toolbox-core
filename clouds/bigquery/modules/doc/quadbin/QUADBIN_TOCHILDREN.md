## QUADBIN_TOCHILDREN

```sql:signature
QUADBIN_TOCHILDREN(quadbin, resolution)
```

**Description**

Returns an array with the children Quadbins of a given Quadbin for a specific resolution. A children Quadbin is a Quadbin of higher level of detail that is contained by the current Quadbin. Each Quadbin has four direct children (at the next higher resolution).

* `quadbin`: `INT64` Quadbin to get the children from.
* `resolution`: `INT64` resolution of the desired children.

**Return type**

`ARRAY<INT64>`

**Example**

```sql
SELECT carto.QUADBIN_TOCHILDREN(5207251884775047167, 5);
-- 5211742290262884351
-- 5211751086355906559
-- 5211746688309395455
-- 5211755484402417663
```
