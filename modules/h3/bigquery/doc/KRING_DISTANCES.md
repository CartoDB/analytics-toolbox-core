### KRING_DISTANCES

{{% bannerNote type="code" %}}
h3.KRING_DISTANCES(origin, size)
{{%/ bannerNote %}}

**Description**

Returns all cell indexes and their distances in a **filled hexagonal k-ring** centered at the origin in no particular order. Returns `null` on invalid input.

* `origin`: `STRING` The H3 cell index of the origin.
* `size`: `INT64` The size of the ring (distance from the origin).

**Return type**

`ARRAY<STRUCT<index STRING, distance INT64>>`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto-os.h3.KRING_DISTANCES('837b59fffffffff', 1);
-- {"index": "837b59fffffffff", "distance": "0"}
-- {"index": "837b5dfffffffff", "distance": "1"}
-- {"index": "837b58fffffffff", "distance": "1"}
-- {"index": "837b5bfffffffff", "distance": "1"}
-- {"index": "837a66fffffffff", "distance": "1"}
-- {"index": "837a64fffffffff", "distance": "1"}
-- {"index": "837b4afffffffff", "distance": "1"}
```