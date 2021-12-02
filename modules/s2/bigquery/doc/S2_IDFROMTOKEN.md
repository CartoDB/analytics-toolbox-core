### S2_IDFROMTOKEN

{{% bannerNote type="code" %}}
carto.S2_IDFROMTOKEN(token)
{{%/ bannerNote %}}

**Description**

Returns the conversion of a token into a S2 cell ID.

* `token`: `STRING` S2 cell hexified ID.

**Return type**

`INT64`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto-os.carto.S2_IDFROMTOKEN('89c25a3000000000');
-- -8520148382826627072
```


