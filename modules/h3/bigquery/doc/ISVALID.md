### ISVALID

{{% bannerNote type="code" %}}
h3.ISVALID(index)
{{%/ bannerNote %}}

**Description**

Returns `true` when the given index is valid, `false` otherwise.

* `index`: `STRING` The H3 cell index.

**Return type**

`BOOLEAN`

**Examples**

```sql
SELECT bqcarto.h3.ISVALID("847b59dffffffff");
-- true
```

```sql
SELECT bqcarto.h3.ISVALID("1");
-- false
```