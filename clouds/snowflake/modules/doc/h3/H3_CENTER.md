## H3_CENTER

```sql:signature
H3_CENTER(index)
```

**Description**

Returns the center of the H3 cell as a GEOGRAPHY point. It will return `null` on error (invalid input).

* `index`: `STRING` The H3 cell index.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT carto.H3_CENTER('847b59dffffffff');
-- { "coordinates": [ 40.30547642317431, -3.743203325561684 ], "type": "Point" }
```
