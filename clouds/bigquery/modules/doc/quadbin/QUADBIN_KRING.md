## QUADBIN_KRING

```sql:signature
QUADBIN_KRING(origin, size)
```

**Description**

Returns all Quadbin cell indexes in a **filled square k-ring** centered at the origin in no particular order.

* `origin`: `INT64` Quadbin index of the origin.
* `size`: `INT64` size of the ring (distance from the origin).

**Return type**

`ARRAY<INT64>`

**Example**

```sql
SELECT carto.QUADBIN_KRING(5207251884775047167, 1);
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
