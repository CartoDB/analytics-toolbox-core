## Reference

### PLACEKEY

#### PLACEKEY_ISVALID

{{% bannerNote type="code" %}}
placekey.PLACEKEY_ISVALID(placekey STRING) -> BOOLEAN
{{%/ bannerNote %}}

Transform a h3 index to an equivalent placekey.

* `placekey`: `STRING` Place identifier.

Returns whether a given string represents a valid H3 index.

#### VERSION

{{% bannerNote type="code" %}}
placekey.VERSION() -> STRING
{{%/ bannerNote %}}

Returns the current version of the placekey library.