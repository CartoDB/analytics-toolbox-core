### PLACEKEY_ISVALID

{{% bannerNote type="code" %}}
carto.PLACEKEY_ISVALID(placekey)
{{%/ bannerNote %}}

**Description**

Returns a boolean value `true` when the given string represents a valid Placekey, `false` otherwise.

* `placekey`: `STRING` Placekey identifier.

**Return type**

`BOOLEAN`

{{% customSelector %}}
**Examples**
{{%/ customSelector %}}

```sql
SELECT `carto-os`.carto.PLACEKEY_ISVALID('@ff7-swh-m49');
-- true
```

```sql
SELECT `carto-os`.carto.PLACEKEY_ISVALID('ff7-swh-m49');
-- true
```

```sql
SELECT `carto-os`.carto.PLACEKEY_ISVALID('x');
-- false
```