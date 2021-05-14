### KRING

{{% bannerNote type="code" %}}
h3.KRING(index, distance)
{{%/ bannerNote %}}

**Description**

Returns an array with the indexes of all hexagons within `distance` of the given input hexagon. The order of the hexagons is undefined. Returns `null` on invalid input.

* `index`: `STRING` The H3 cell index as hexadecimal.
* `distance`: `INT` distance (in number of cells) to the source.

**Return type**

`ARRAY`

**Example**

```sql
SELECT sfcarto.h3.KRING('837b59fffffffff', 1);
-- 837b59fffffffff
-- 837b58fffffffff
-- 837b5bfffffffff
-- 837a66fffffffff
-- 837a64fffffffff
-- 837b4afffffffff
-- 837b5dfffffffff
```