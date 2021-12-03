### S2_TOTOKEN

{{% bannerNote type="code" %}}
carto.S2_TOTOKEN(id)
{{%/ bannerNote %}}

**Description**

Returns the conversion of a S2 cell ID into a token (S2 cell hexified ID).

* `id`: `INT64` S2 cell ID.

**Return type**

`STRING`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto-os.carto.S2_TOTOKEN(-8520148382826627072);
-- 89c25a3000000000
```


