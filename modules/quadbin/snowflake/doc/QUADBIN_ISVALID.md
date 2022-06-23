### QUADBIN_ISVALID

{{% bannerNote type="code" %}}
carto.QUADBIN_ISVALID(quadbin)
{{%/ bannerNote %}}

**Description**

Returns `true` when the given index is valid, `false` otherwise.

* `quadbin`: `INT` quadbin index.

**Return type**

`BOOLEAN`

{{% customSelector %}}
**Examples**
{{%/ customSelector %}}

```sql
SELECT carto.QUADBIN_ISVALID(5209574053332910079);
-- true
```

```sql
SELECT carto.QUADBIN_ISVALID(1234);
-- false
```