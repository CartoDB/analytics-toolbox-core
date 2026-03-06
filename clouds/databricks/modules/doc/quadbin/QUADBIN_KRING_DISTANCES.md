## QUADBIN_KRING_DISTANCES

```sql:signature
QUADBIN_KRING_DISTANCES(origin, size)
```

**Description**

Returns all cell indexes and their distances in a **filled square k-ring** centered at the origin in no particular order.

* `origin`: `BIGINT` Quadbin index of the origin.
* `size`: `INT` size of the ring (distance from the origin).

**Return type**

`ARRAY<STRUCT<index: BIGINT, distance: INT>>`

**Example**

```sql
SELECT carto.QUADBIN_KRING_DISTANCES(5207251884775047167, 1);
-- [{"index": 5207128739472736255, "distance": 1},
--  {"index": 5207234292589002751, "distance": 1},
--  ...
--  {"index": 5207251884775047167, "distance": 0},
--  ...]
```

```hint:info
**tip**

The distance of the rings is computed as the [Chebyshev distance](https://en.wikipedia.org/wiki/Chebyshev_distance).

```
