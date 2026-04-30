## QUADBIN_KRING

```sql:signature
QUADBIN_KRING(origin, size)
```

**Description**

Returns all cell indexes in a **filled square k-ring** centered at the origin in no particular order.

**Input parameters**

* `origin`: `NUMBER` Quadbin index of the origin.
* `size`: `NUMBER` size of the ring (distance from the origin).

**Return type**

`QUADBIN_INDEX_ARRAY` (pipelined `TABLE OF NUMBER`)

**Example**

```sql
SELECT COLUMN_VALUE
FROM TABLE(carto.QUADBIN_KRING(5207251884775047167, 1));
-- 5207128739472736255
-- 5207234292589002751
-- 5207269476961091583
-- 5207146331658780671
-- 5207251884775047167
-- 5207287069147135999
-- 5207902795658690559
-- 5208008348774957055
-- 5208043533147045887
```
