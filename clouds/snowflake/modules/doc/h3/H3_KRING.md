## H3_KRING

```sql:signature
H3_KRING(origin, size)
```

**Description**

Returns all cell indexes in a **filled hexagonal k-ring** centered at the origin in no particular order.

* `origin`: `STRING` H3 cell index of the origin.
* `size`: `INT` size of the ring (distance from the origin).

**Return type**

`ARRAY`

**Example**

```sql
SELECT carto.H3_KRING('84390cbffffffff', 1);
-- 84390cbffffffff
-- 84390c9ffffffff
-- 84390c1ffffffff
-- 84390c3ffffffff
-- 84390ddffffffff
-- 84392b7ffffffff
-- 84392b5ffffffff
```
