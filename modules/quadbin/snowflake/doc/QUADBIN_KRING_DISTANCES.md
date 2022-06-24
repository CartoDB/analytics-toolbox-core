### QUADBIN_KRING_DISTANCES

{{% bannerNote type="code" %}}
carto.QUADBIN_KRING_DISTANCES(origin, size)
{{%/ bannerNote %}}

**Description**

Returns all cell indexes and their distances in a **filled square k-ring** centered at the origin in no particular order.

* `origin`: `INT` quadbin index of the origin.
* `size`: `INT` size of the ring (distance from the origin).

**Return type**

`ARRAY<STRUCT<index INT, distance INT>>`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto.QUADBIN_KRING_DISTANCES(5209574053332910079, 1);
-- {"index": "5208043533147045887", "distance": "1"}
-- {"index": "5209556461146865663", "distance": "1"}
-- {"index": "5209591645518954495", "distance": "1"}
-- {"index": "5208061125333090303", "distance": "1"}
-- {"index": "5209574053332910079", "distance": "0"}
-- {"index": "5209609237704998911", "distance": "1"}
-- {"index": "5208113901891223551", "distance": "1"}
-- {"index": "5209626829891043327", "distance": "1"}
-- {"index": "5209662014263132159", "distance": "1"}
```

{{% bannerNote type="note" title="tip"%}}
The distance of the rings is computed as the [Chebyshev distance](https://en.wikipedia.org/wiki/Chebyshev_distance).
{{%/ bannerNote %}}