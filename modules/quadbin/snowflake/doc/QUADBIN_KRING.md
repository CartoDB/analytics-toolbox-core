### QUADBIN_KRING

{{% bannerNote type="code" %}}
carto.QUADBIN_KRING(origin, size)
{{%/ bannerNote %}}

**Description**

Returns all cell indexes in a **filled square k-ring** centered at the origin in no particular order.

* `origin`: `INT` quadbin index of the origin.
* `size`: `INT` size of the ring (distance from the origin).

**Return type**

`ARRAY<INT>`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto.QUADBIN_KRING(4388, 1);
-- 5208043533147045887
-- 5209556461146865663
-- 5209591645518954495
-- 5208061125333090303
-- 5209574053332910079
-- 5209609237704998911
-- 5208113901891223551
-- 5209626829891043327
-- 5209662014263132159
```