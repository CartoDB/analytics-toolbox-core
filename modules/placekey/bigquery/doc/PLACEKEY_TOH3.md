### PLACEKEY_TOH3

{{% bannerNote type="code" %}}
carto.PLACEKEY_TOH3(placekey)
{{%/ bannerNote %}}

**Description**

Returns the H3 index equivalent to the given placekey.

* `placekey`: `STRING` Placekey identifier.

**Return type**

`STRING`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto-os.carto.PLACEKEY_TOH3('@ff7-swh-m49');
-- 8a7b59dffffffff
```