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
SELECT carto.H3_HEXRING('837b59fffffffff', 1);
-- { 837b5dfffffffff,
--   837b58fffffffff,
--   837b5bfffffffff,
--   837a66fffffffff,
--   837a64fffffffff,
--   837b4afffffffff }
```