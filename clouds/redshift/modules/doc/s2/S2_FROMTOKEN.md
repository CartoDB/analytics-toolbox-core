### S2_FROMTOKEN

{{% bannerNote type="code" %}}
carto.S2_FROMTOKEN(token)
{{%/ bannerNote %}}

**Description**

Returns the conversion of an S2 cell token (hexified ID) into an unsigned, 64 bit ID.

* `token`: `VARCHAR(MAX)` S2 cell token.

**Return type**

`INT8`

**Example**

```sql
SELECT carto.S2_FROMTOKEN('89c25a3');
-- -8520148382826627072
```
