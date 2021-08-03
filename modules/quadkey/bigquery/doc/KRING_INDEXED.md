### KRING_INDEXED

{{% bannerNote type="code" %}}
quadkey.KRING_INDEXED(quadint, distance)
{{%/ bannerNote %}}

**Description**

Returns an array containing all the quadints directly next to the given quadint at the same level of zoom. Diagonal, horizontal and vertical nearby quadints plus the current quadint are considered, so KRING_INDEXED always returns `(distance*2 + 1)^2` quadints.

* `quadint`: `INT64` quadint to get the KRING_INDEXED from.
* `distance`: `INT64` distance (in cells) to the source.

**Return type**

`ARRAY<INT64>`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto-os.quadkey.KRING_INDEXED(4388, 1);
-- 3844
-- 3876
-- 3908
-- 4356
-- 4388
-- 4420
-- 4868
-- 4900
-- 4932
```