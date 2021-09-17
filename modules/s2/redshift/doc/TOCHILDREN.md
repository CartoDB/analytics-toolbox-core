### TOCHILDREN

{{% bannerNote type="code" %}}
s2.TOCHILDREN(id, resolution)
{{%/ bannerNote %}}

**Description**

Returns a SUPER containing a plain array of children IDs of a given cell ID for a specific resolution.
A child is an S2 cell of higher level of detail that is contained by the current cell.
Each cell has four direct children by definition.

By default, this function returns the direct children (where parent resolution is children resolution - 1).
However, an optional resolution argument can be passed with the desired parent resolution.
Note that the amount of children grows to the power of four per zoom level.

* `id`: `INT8` id to get the children from.

Optional arguments:

* `resolution`: `INT` resolution of the desired children.

**Return type**

`ARRAY`

**Example**

```sql
SELECT s2.TOCHILDREN(1733885856537640960);
-- [1730508156817113088,1732759956630798336,1735011756444483584,1737263556258168832]

SELECT s2.TOCHILDREN(1733885856537640960, 6);
-- 1729663731886981120,1730226681840402432,1730789631793823744,1731352581747245056,1731915531700666368,1732 478481654087680,1733041431607508992,1733604381560930304,1734167331514351616,1734730281467772928,173529323 1421194240,1735856181374615552,1736419131328036864,1736982081281458176,1737545031234879488,1738107981188300800
```
