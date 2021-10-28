### H3_ISVALID

{{% bannerNote type="code" %}}
h3.H3_ISVALID(index)
{{%/ bannerNote %}}

**Description**

Returns `true` when the given index is valid, `false` otherwise.

* `index`: `STRING` The H3 cell index as hexadecimal.

**Return type**

`BOOLEAN`

**Examples**

```sql
SELECT sfcarto.h3.H3_ISVALID('847b59dffffffff');
-- true
```

```sql
SELECT sfcarto.h3.H3_ISVALID('1');
-- false
```