### H3_KRING_DISTANCES

{{% bannerNote type="code" %}}
carto.H3_KRING_DISTANCES(origin, size)
{{%/ bannerNote %}}

**Description**

Returns all cell indexes and their distances in a **filled hexagonal k-ring** centered at the origin in no particular order.

* `origin`: `STRING` H3 cell index of the origin.
* `size`: `INT` size of the ring (distance from the origin).

**Return type**

`ARRAY`

**Example**

```sql
SELECT carto.H3_KRING_DISTANCES('837b59fffffffff', 1);
-- {"index": "837b59fffffffff", "distance": 0}
-- {"index": "837b5dfffffffff", "distance": 1}
-- {"index": "837b58fffffffff", "distance": 1}
-- {"index": "837b5bfffffffff", "distance": 1}
-- {"index": "837a66fffffffff", "distance": 1}
-- {"index": "837a64fffffffff", "distance": 1}
-- {"index": "837b4afffffffff", "distance": 1}
```
