### QUADBIN_ISVALID

{{% bannerNote type="code" %}}
carto.QUADBIN_ISVALID(quadbin)
{{%/ bannerNote %}}

**Description**

Returns `true` when the given index is a valid Quadbin, `false` otherwise.

* `quadbin`: `INT64` Quadbin index.

**Return type**

`BOOLEAN`

{{% customSelector %}}
**Examples**
{{%/ customSelector %}}

```sql
SELECT `carto-os`.carto.QUADBIN_ISVALID(5209574053332910079);
-- true
```

```sql
SELECT `carto-os`.carto.QUADBIN_ISVALID(1234);
-- false
```
