### TOKEN_FROMID

{{% bannerNote type="code" %}}
s2.TOKEN_FROMID(id)
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
SELECT carto-os.s2.TOKEN_FROMID(-8520148382826627072);
-- 89c25a3000000000
```


