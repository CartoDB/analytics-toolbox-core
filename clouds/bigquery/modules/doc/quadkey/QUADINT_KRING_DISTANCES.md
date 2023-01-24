## QUADINT_KRING_DISTANCES

```sql:signature
carto.QUADINT_KRING_DISTANCES(origin, size)
```

**Description**

Returns all cell indexes and their distances in a **filled square k-ring** centered at the origin in no particular order.

* `origin`: `INT64` quadint index of the origin.
* `size`: `INT64` size of the ring (distance from the origin).

**Return type**

`ARRAY<STRUCT<index INT64, distance INT64>>`

**Example**

```sql
SELECT `carto-os`.carto.QUADINT_KRING_DISTANCES(4388, 1);
-- {"index": "4388", "distance": "0"}
-- {"index": "4932", "distance": "1"}
-- {"index": "4900", "distance": "1"}
-- {"index": "4868", "distance": "1"}
-- {"index": "4420", "distance": "1"}
-- {"index": "4356", "distance": "1"}
-- {"index": "3908", "distance": "1"}
-- {"index": "3876", "distance": "1"}
-- {"index": "3844", "distance": "1"}
```

````hint:info
**tip**

The distance of the rings is computed as the [Chebyshev distance](https://en.wikipedia.org/wiki/Chebyshev_distance).

````
