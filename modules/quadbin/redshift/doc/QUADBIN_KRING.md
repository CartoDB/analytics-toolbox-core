### QUADBIN_KRING

{{% bannerNote type="code" %}}
carto.QUADBIN_KRING(origin, size)
{{%/ bannerNote %}}

**Description**

Returns all cell indexes in a **filled square k-ring** centered at the origin in no particular order.

* `origin`: `BIGINT` quadbin index of the origin.
* `size`: `INT` size of the ring (distance from the origin).

**Return type**

`SUPER`

**Example**

```sql
SELECT carto.QUADBIN_KRING(4388, 1);
-- 3844
-- 3876
-- 3908
-- 4356
-- 4388
-- 4420
-- 4868
-- 4900
-- 4932
```