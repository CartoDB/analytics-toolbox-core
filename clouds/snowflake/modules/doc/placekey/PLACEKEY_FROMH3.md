### PLACEKEY_FROMH3

{{% bannerNote type="code" %}}
carto.PLACEKEY_FROMH3(h3index)
{{%/ bannerNote %}}

**Description**

Returns the placekey equivalent to the given H3 index.

* `h3index`: `STRING` H3 identifier.

**Return type**

`STRING`

**Example**

```sql
SELECT carto.PLACEKEY_FROMH3('847b59dffffffff');
-- @ff7-swh-m49
```