### H3_ISVALID

{{% bannerNote type="code" %}}
carto.H3_ISVALID(index)
{{%/ bannerNote %}}

**Description**

Returns `true` when the given index is a valid H3 index, `false` otherwise.

* `index`: `STRING` The H3 cell index.

**Return type**

`BOOLEAN`

{{% customSelector %}}
**Examples**
{{%/ customSelector %}}

```sql
SELECT `carto-os`.carto.H3_ISVALID('847b59dffffffff');
-- true
```

```sql
SELECT `carto-os`.carto.H3_ISVALID('1');
-- false
```
