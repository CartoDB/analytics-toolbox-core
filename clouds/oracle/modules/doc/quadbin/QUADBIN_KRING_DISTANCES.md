## QUADBIN_KRING_DISTANCES

```sql:signature
QUADBIN_KRING_DISTANCES(origin, size)
```

**Description**

Returns all cell indexes and their distances in a **filled square k-ring** centered at the origin in no particular order.

**Input parameters**

* `origin`: `NUMBER` Quadbin index of the origin.
* `size`: `NUMBER` size of the ring (distance from the origin).

**Return type**

`QUADBIN_DISTANCE_ARRAY` (pipelined `TABLE OF QUADBIN_DISTANCE_PAIR`, fields `quadbin_index`, `distance`)

**Example**

```sql
SELECT t.quadbin_index, t.distance
FROM TABLE(carto.QUADBIN_KRING_DISTANCES(5207251884775047167, 1)) t;
-- QUADBIN_INDEX        DISTANCE
-- 5207128739472736255  1
-- 5207234292589002751  1
-- 5207269476961091583  1
-- 5207146331658780671  1
-- 5207251884775047167  0
-- 5207287069147135999  1
-- 5207902795658690559  1
-- 5208008348774957055  1
-- 5208043533147045887  1
```

````hint:info
**tip**

The distance of the rings is computed as the [Chebyshev distance](https://en.wikipedia.org/wiki/Chebyshev_distance).

````
