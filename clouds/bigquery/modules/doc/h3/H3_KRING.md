## H3_KRING

```sql:signature
H3_KRING(origin, size)
```

**Description**

Returns all cell indexes in a **filled hexagonal k-ring** centered at the origin in no particular order.

* `origin`: `STRING` H3 cell index of the origin.
* `size`: `INT64` size of the ring (distance from the origin).

**Return type**

`ARRAY<STRING>`

**Example**

```sql
SELECT carto.H3_KRING('837b59fffffffff', 1);
-- 837b59fffffffff
-- 837b58fffffffff
-- 837b5bfffffffff
-- 837a66fffffffff
-- 837a64fffffffff
-- 837b4afffffffff
-- 837b5dfffffffff
```
