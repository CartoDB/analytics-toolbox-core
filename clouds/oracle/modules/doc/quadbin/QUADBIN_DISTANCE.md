## QUADBIN_DISTANCE

```sql:signature
QUADBIN_DISTANCE(origin, destination)
```

**Description**

Returns the [Chebyshev distance](https://en.wikipedia.org/wiki/Chebyshev_distance) between two quadbin indexes. The origin and destination indices must have the same resolution. Otherwise `NULL` will be returned.

**Input parameters**

* `origin`: `NUMBER` origin quadbin index.
* `destination`: `NUMBER` destination quadbin index.

**Return type**

`NUMBER`

**Example**

```sql
SELECT carto.QUADBIN_DISTANCE(5207251884775047167, 5207128739472736255) FROM DUAL;
-- 1
```
