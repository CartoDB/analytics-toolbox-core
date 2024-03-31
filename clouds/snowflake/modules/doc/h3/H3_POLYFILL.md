## H3_POLYFILL

```sql:signature
H3_POLYFILL(geography, resolution)  
H3_POLYFILL(geography, resolution, mode)
```

**Description**

Returns an array with all H3 cell indicies contained in the given polygon. There are three modes which decide if a H3 cell is contained in the polygon:  

- **center** (Default) - The center point of the H3 cell must be within the polygon
- **contains** - the H3 cell must be fully contained within the polygon (least inclusive)
- **intersects** - The H3 cell intersects in any way with the polygon (most inclusive)

- `geography`: `GEOGRAPHY` **polygon** or **multipolygon** representing the shape to cover. **GeometryCollections** are also allowed but they should contain **polygon** or **multipolygon** geographies. Non-Polygon types will not raise an error but will be ignored instead.
- `resolution`: `INT` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).
- `mode`: `STRING` `<center|contains|intersects>`. Optional. Defaults to 'center' mode.

**Return type**

`ARRAY`

**Example**

```sql
SELECT carto.H3_POLYFILL(
    TO_GEOGRAPHY('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))'), 4, 'center');
-- 842da29ffffffff
-- 843f725ffffffff
-- 843eac1ffffffff
-- 8453945ffffffff
-- ...
```
