### KRING_INDEXED

{{% bannerNote type="code" %}}
quadkey.KRING_INDEXED(quadint, distance)
{{%/ bannerNote %}}

**Description**

Returns an array containing all the quadints and their relative position to the given quadint in term of x and y. Quadints returned are directly next to the given quadint at the same level of zoom. Diagonal, horizontal and vertical nearby quadints plus the current quadint are considered, so KRING_INDEXED always returns `(distance*2 + 1)^2` quadints.

* `x`: `INT64` distance along x axis relative to the given quadint (in cells).
* `y`: `INT64` distance along y axis relative to the given quadint (in cells).
* `idx`: `INT64` quadint to get the KRING_INDEXED from.

**Return type**

`ARRAY<STRUCT<x INT64, y INT64, idx INT64>>`


{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto-os.quadkey.KRING_INDEXED(4388, 1) mykring_indexed;
--     "mykring_indexed": [
      {
        "x": "-1",
        "y": "-1",
        "idx": "3844"
      },
      {
        "x": "0",
        "y": "-1",
        "idx": "3876"
      },
      {
        "x": "1",
        "y": "-1",
        "idx": "3908"
      },
      {
        "x": "-1",
        "y": "0",
        "idx": "4356"
      },
      {
        "x": "0",
        "y": "0",
        "idx": "4388"
      },
      {
        "x": "1",
        "y": "0",
        "idx": "4420"
      },
      {
        "x": "-1",
        "y": "1",
        "idx": "4868"
      },
      {
        "x": "0",
        "y": "1",
        "idx": "4900"
      },
      {
        "x": "1",
        "y": "1",
        "idx": "4932"
      }
    ]
```
