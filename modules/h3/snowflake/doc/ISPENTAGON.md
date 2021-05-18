### ISPENTAGON

{{% bannerNote type="code" %}}
h3.ISPENTAGON(index)
{{%/ bannerNote %}}

**Description**

Returns `true` if given H3 index is a pentagon. Returns `false` otherwise, even on invalid input.

* `index`: `STRING` The H3 cell index as hexadecimal.

**Return type**

`BOOLEAN`

**Example**

```sql
SELECT sfcarto.h3.ISPENTAGON('837B59FFFFFFFFF');
-- false
```