### H3_ISPENTAGON

{{% bannerNote type="code" %}}
h3.H3_ISPENTAGON(index)
{{%/ bannerNote %}}

**Description**

Returns `true` if given H3 index is a pentagon. Returns `false` otherwise, even on invalid input.

* `index`: `STRING` The H3 cell index.

**Return type**

`BOOLEAN`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto-os.h3.H3_ISPENTAGON('837b59fffffffff');
-- false
```

```sql
SELECT carto-os.h3.H3_ISPENTAGON('8075fffffffffff');
-- true
```