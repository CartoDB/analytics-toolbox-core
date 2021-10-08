### TOKEN_FROMID

{{% bannerNote type="code" %}}
s2.TOKEN_FROMID(id)
{{%/ bannerNote %}}

**Description**

Returns the conversion of a S2 cell ID into a token (S2 cell hexified ID).

* `id`: `INT8` S2 cell ID.

**Return type**

`VARCHAR(MAX)`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT s2.TOKEN_FROMID(-8520148382826627072);
-- 89c25a3
```


