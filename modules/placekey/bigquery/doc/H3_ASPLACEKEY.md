### H3_ASPLACEKEY

{{% bannerNote type="code" %}}
placekey.H3_ASPLACEKEY(h3index)
{{%/ bannerNote %}}

**Description**

Returns the placekey equivalent to the given H3 index.

* `h3index`: `STRING` H3 identifier.

**Return type**

`STRING`

**Example**

```sql
SELECT bqcarto.placekey.H3_ASPLACEKEY("847b59dffffffff");
-- @ff7-swh-m49
```
