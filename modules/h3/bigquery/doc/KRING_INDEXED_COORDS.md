### KRING_INDEXED_COORDS

{{% bannerNote type="code" %}}
quadkey.KRING_INDEXED_COORDS(quadint, distance)
{{%/ bannerNote %}}

**Description**

Returns an array with the indexes and their `distance` in term of cell to the given input hexagon of all hexagons within `distance`. The order of the hexagons is undefined. Returns `null` on invalid input.

- The coordinate space used by this function may have deleted
regions or warping due to pentagonal distortion.
- Failure may occur if the asked kring distance is too large
or if the kring cover the other side of a pentagon.
- This function is experimental, and its output is not guaranteed
to be compatible across different versions.

* `idx`: `INT64` quadint to get the KRING_INDEXED_COORDS from.
* `i`: `INT64` distance along i axis relative to the given quadint (in cells).
* `j`: `INT64` distance along j axis relative to the given quadint (in cells).

**Return type**

`ARRAY<STRUCT<x INT64, y INT64, idx INT64>>`


{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto-os.h3.KRING_INDEXED_COORDS('837b59fffffffff', 1) myKRING_INDEXED_COORDS;
--     "myKRING_INDEXED_COORDS": [
      {
        "idx": "837b59fffffffff",
        "i": "0",
        "j": "0"
      },
      {
        "idx": "837b5dfffffffff",
        "i": "-1",
        "j": "0"
      },
      {
        "idx": "837b58fffffffff",
        "i": "-1",
        "j": "-1"
      },
      {
        "idx": "837b5bfffffffff",
        "i": "0",
        "j": "-1"
      },
      {
        "idx": "837a66fffffffff",
        "i": "1",
        "j": "0"
      },
      {
        "idx": "837a64fffffffff",
        "i": "1",
        "j": "1"
      },
      {
        "idx": "837b4afffffffff",
        "i": "0",
        "j": "1"
      }
    ]
```