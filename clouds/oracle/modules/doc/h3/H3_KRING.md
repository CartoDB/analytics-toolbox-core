## H3_KRING

```sql:signature
H3_KRING(origin, size)
```

**Description**

Returns all cell indexes in a **filled hexagonal k-ring** centered at the origin in no particular order. Returns no rows for invalid input or negative `size`.

**Input parameters**

* `origin`: `VARCHAR2(16)` H3 cell index of the origin.
* `size`: `NUMBER` size of the ring (distance from the origin).

**Return type**

`H3_INDEX_ARRAY` (pipelined; `TABLE OF VARCHAR2(16)`).

**Example**

```sql
SELECT COLUMN_VALUE AS h3
FROM TABLE(carto.H3_KRING('84390cbffffffff', 1));
-- 84390cbffffffff
-- 84390c9ffffffff
-- 84390c1ffffffff
-- 84390c3ffffffff
-- 84390ddffffffff
-- 84392b7ffffffff
-- 84392b5ffffffff
```
