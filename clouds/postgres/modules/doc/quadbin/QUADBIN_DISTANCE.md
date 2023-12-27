## QUADBIN_DISTANCE

```sql:signature
QUADBIN_DISTANCE(origin, destination)
```

**Description**

Returns the **Chebyshev distance** between two quadbin indexes. Returns `null` on invalid inputs.

* `origin`: `BIGINT` origin quadbin index.
* `destination`: `BIGINT` destination quadbin index.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT carto.QUADBIN_DISTANCE(5207251884775047167, 5207128739472736255);
-- 1
```
