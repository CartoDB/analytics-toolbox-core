## H3_HEXRING

```sql:signature
H3_HEXRING(origin, size)
```

**Description**

Returns all cell indexes in a **hollow hexagonal ring** centered at the origin in no particular order. Unlike [H3_KRING](h3#h3_kring), this function will throw an exception if there is a pentagon anywhere in the ring.

* `origin`: `VARCHAR(16)` H3 cell index of the origin.
* `size`: `INT` size of the ring (distance from the origin).

**Return type**

`VARCHAR(16)[]`

**Example**

```sql
SELECT carto.H3_HEXRING('84390cbffffffff', 1);
-- { 84392b5ffffffff,
--   84390c9ffffffff,
--   84390c1ffffffff,
--   84390c3ffffffff,
--   84390ddffffffff,
--   84392b7ffffffff }
```
