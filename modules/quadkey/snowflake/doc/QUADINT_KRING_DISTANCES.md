### QUADINT_KRING_DISTANCES

{{% bannerNote type="code" %}}
quadkey.QUADINT_KRING_DISTANCES(origin, size)
{{%/ bannerNote %}}

**Description**

Returns all cell indexes and their distances in a **filled square k-ring** centered at the origin in no particular order.

* `origin`: `BIGINT` quadint index of the origin.
* `size`: `INT` size of the ring (distance from the origin).

**Return type**

`ARRAY`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT sfcarto.quadkey.QUADINT_KRING_DISTANCES(4388, 1);
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

{{% bannerNote type="note" title="tip"%}}
The distance of the rings is computed as the [Chebyshev distance](https://en.wikipedia.org/wiki/Chebyshev_distance).
{{%/ bannerNote %}}