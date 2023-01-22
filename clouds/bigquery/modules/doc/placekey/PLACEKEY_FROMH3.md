## PLACEKEY_FROMH3

```sql:signature
carto.PLACEKEY_FROMH3(h3index)
```

**Description**

Returns the placekey equivalent of the given H3 index.

* `h3index`: `STRING` H3 identifier.

**Return type**

`STRING`


**Example**


```sql
SELECT `carto-os`.carto.PLACEKEY_FROMH3('847b59dffffffff');
-- @ff7-swh-m49
```