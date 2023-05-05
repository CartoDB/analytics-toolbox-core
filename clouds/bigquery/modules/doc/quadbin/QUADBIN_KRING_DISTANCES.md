## QUADBIN_KRING_DISTANCES

```sql:signature
QUADBIN_KRING_DISTANCES(origin, size)
```

**Description**

Returns all Quadbin cell indexes and their distances in a **filled square k-ring** centered at the origin in no particular order.

* `origin`: `INT64` Quadbin index of the origin.
* `size`: `INT64` size of the ring (distance from the origin).

**Return type**

`ARRAY<STRUCT<index INT64, distance INT64>>`

**Example**

```sql
SELECT carto.QUADBIN_KRING_DISTANCES(5207251884775047167, 1);
-- {"index": "5207128739472736255", "distance": "1"}
-- {"index": "5207234292589002751", "distance": "1"}
-- {"index": "5207269476961091583", "distance": "1"}
-- {"index": "5207146331658780671", "distance": "1"}
-- {"index": "5207251884775047167", "distance": "0"}
-- {"index": "5207287069147135999", "distance": "1"}
-- {"index": "5207902795658690559", "distance": "1"}
-- {"index": "5208008348774957055", "distance": "1"}
-- {"index": "5208043533147045887", "distance": "1"}
```

````hint:info
**tip**

The distance of the rings is computed as the [Chebyshev distance](https://en.wikipedia.org/wiki/Chebyshev_distance).
````
