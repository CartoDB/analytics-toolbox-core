## H3_HEXRING

```sql:signature
H3_HEXRING(origin, size)
```

**Description**

Returns all cell indexes in a **hollow hexagonal ring** centered at the origin in no particular order. For `size = 0` returns just the origin. Returns no rows for invalid input or negative `size`.

**Input parameters**

* `origin`: `VARCHAR2(16)` H3 cell index of the origin.
* `size`: `NUMBER` size of the ring (distance from the origin).

**Return type**

`H3_INDEX_ARRAY` (pipelined; `TABLE OF VARCHAR2(16)`).

**Example**

```sql
SELECT COLUMN_VALUE AS h3
FROM TABLE(carto.H3_HEXRING('84390cbffffffff', 1));
-- 84392b5ffffffff
-- 84390c9ffffffff
-- 84390c1ffffffff
-- 84390c3ffffffff
-- 84390ddffffffff
-- 84392b7ffffffff
```
