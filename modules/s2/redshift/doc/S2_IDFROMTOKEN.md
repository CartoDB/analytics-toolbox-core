### S2_IDFROMTOKEN

{{% bannerNote type="code" %}}
s2.S2_IDFROMTOKEN(token)
{{%/ bannerNote %}}

**Description**

Returns the conversion of an S2 cell token (hexified ID) into an unsigned,64 bit ID

* `token`: `VARCHAR(MAX)` S2 cell token.

**Return type**

`INT8`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT s2.S2_IDFROMTOKEN('89c25a3');
-- -8520148382826627072
```