### HEXRING

{{% bannerNote type="code" %}}
h3.HEXRING(index, distance)
{{%/ bannerNote %}}

**Description**

Get all hexagons in a **hollow hexagonal ring** centered at origin with sides of a given length. Unlike KRING, this function will return `null` if there is a pentagon anywhere in the ring.

* `index`: `STRING` The H3 cell index.
* `distance`: `INT64` distance (in cells) to the source.

**Return type**

`ARRAY<STRING>`

**Example**

```sql
SELECT bqcarto.h3.HEXRING('837b59fffffffff', 1);
-- 837b5dfffffffff
-- 837b58fffffffff
-- 837b5bfffffffff
-- 837a66fffffffff
-- 837a64fffffffff
-- 837b4afffffffff
```