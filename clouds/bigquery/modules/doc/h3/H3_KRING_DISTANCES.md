## H3_KRING_DISTANCES

```sql:signature
H3_KRING_DISTANCES(origin, size)
```

**Description**

Returns all cell indexes and their distances in a **filled hexagonal k-ring** centered at the origin in no particular order.

* `origin`: `STRING` H3 cell index of the origin.
* `size`: `INT64` size of the ring (distance from the origin).

**Return type**

`ARRAY<STRUCT<index STRING, distance INT64>>`

**Example**

```sql
SELECT carto.H3_KRING_DISTANCES('84390cbffffffff', 1);
-- {"index": "84390cbffffffff", "distance": "0"}
-- {"index": "84390c9ffffffff", "distance": "1"}
-- {"index": "84390c1ffffffff", "distance": "1"}
-- {"index": "84390c3ffffffff", "distance": "1"}
-- {"index": "84390ddffffffff", "distance": "1"}
-- {"index": "84392b7ffffffff", "distance": "1"}
-- {"index": "84392b5ffffffff", "distance": "1"}
```
