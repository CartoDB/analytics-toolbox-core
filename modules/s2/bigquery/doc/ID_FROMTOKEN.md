### ID_FROMTOKEN

{{% bannerNote type="code" %}}
s2.ID_FROMTOKEN(token)
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
SELECT carto-os.s2.ID_FROMTOKEN('89c25a3000000000');
-- -8520148382826627072
```


