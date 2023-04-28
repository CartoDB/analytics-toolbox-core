## H3_TOCHILDREN

```sql:signature
H3_TOCHILDREN(index, resolution)
```

**Description**

Returns an array with the H3 indexes of the children/descendents of the given hexagon at the given resolution.

* `index`: `STRING` The H3 cell index.
* `resolution`: `INT64` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`ARRAY<STRING>`

**Example**

```sql
SELECT carto.H3_TOCHILDREN('83390cfffffffff', 4);
-- 84390c1ffffffff
-- 84390c3ffffffff
-- 84390c5ffffffff
-- 84390c7ffffffff
-- 84390c9ffffffff
-- 84390cbffffffff
-- 84390cdffffffff
```
