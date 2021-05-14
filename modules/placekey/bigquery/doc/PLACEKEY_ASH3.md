### PLACEKEY_ASH3

{{% bannerNote type="code" %}}
placekey.PLACEKEY_ASH3(placekey)
{{%/ bannerNote %}}

**Description**

Returns the H3 index equivalent to the given placekey.

* `placekey`: `STRING` Placekey identifier.

**Return type**

`STRING`

**Example**

```sql
SELECT bqcarto.placekey.PLACEKEY_ASH3('@ff7-swh-m49');
-- 8a7b59dffffffff
```