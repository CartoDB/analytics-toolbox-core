## H3_KRING_DISTANCES

```sql:signature
H3_KRING_DISTANCES(origin, size)
```

**Description**

Returns all cell indexes and their distances in a **filled hexagonal k-ring** centered at the origin in no particular order. Returns no rows for invalid input or negative `size`.

**Input parameters**

* `origin`: `VARCHAR2(16)` H3 cell index of the origin.
* `size`: `NUMBER` size of the ring (distance from the origin).

**Return type**

`H3_DISTANCE_ARRAY` (pipelined; `TABLE OF H3_DISTANCE_PAIR(h3 VARCHAR2(16), distance NUMBER)`). Project the named fields when consuming with `TABLE(...)`.

**Example**

```sql
SELECT t.h3, t.distance
FROM TABLE(carto.H3_KRING_DISTANCES('84390cbffffffff', 1)) t;
-- H3               DISTANCE
-- 84390cbffffffff  0
-- 84390c9ffffffff  1
-- 84390c1ffffffff  1
-- 84390c3ffffffff  1
-- 84390ddffffffff  1
-- 84392b7ffffffff  1
-- 84392b5ffffffff  1
```
