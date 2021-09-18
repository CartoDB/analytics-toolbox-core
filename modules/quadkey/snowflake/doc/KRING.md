### KRING

{{% bannerNote type="code" %}}
quadkey.KRING(origin, size)
{{%/ bannerNote %}}

**Description**

Returns all cell indexes in a **filled square k-ring** centered at the origin in no particular order. Returns `null` on invalid input.

* `origin`: `BIGINT` quadint index of the origin.
* `size`: `INT64` size of the ring (distance from the origin).

**Return type**

`ARRAY`

**Example**

```sql
SELECT sfcarto.quadkey.KRING(4388, 1);
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