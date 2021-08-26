### KRING_INDEXED

{{% bannerNote type="code" %}}
h3.KRING_INDEXED(index, distance)
{{%/ bannerNote %}}

**Description**

Returns an array with the indexes and their `distance` in term of cell to the given input hexagon of all hexagons within `distance`. The order of the hexagons is undefined. Returns `null` on invalid input.

* `index`: `STRING` The H3 cell index.
* `distance`: `INT64` distance (in number of cells) to the source.

**Return type**

`ARRAY<STRUCT<idx STRING, distance INT64>>`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto-os.h3.KRING_INDEXED('837b59fffffffff', 1);
-- [{"idx": "837b59fffffffff", "distance": "0"},
--  {"idx": "837b5dfffffffff", "distance": "1"},
--  {"idx": "837b58fffffffff", "distance": "1"},
--  {"idx": "837b5bfffffffff", "distance": "1"},
--  {"idx": "837a66fffffffff", "distance": "1"},
--  {"idx": "837a64fffffffff", "distance": "1"},
--  {"idx": "837b4afffffffff", "distance": "1"}]
