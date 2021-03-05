## Reference

### PLACEKEY

[Placekey](https://www.placekey.io/faq) is a free and open universal standard identifier for any physical place, so that the data pertaining to those places can be shared across organizations easily. Since Placekey is based on H3, here we offer a way to transform to and from that index and delegate any extra functionality to the H3 itself.

#### H3_ASPLACEKEY

{{% bannerNote type="code" %}}
placekey.H3_ASPLACEKEY(h3index INT64) -> STRING
{{%/ bannerNote %}}

* `h3index`: `INT64` H3 identifier.

Transforms a h3 index to the equivalent placekey.


#### PLACEKEY_ASH3

{{% bannerNote type="code" %}}
placekey.PLACEKEY_ASH3(placekey STRING) -> INT64
{{%/ bannerNote %}}

* `placekey`: `STRING` Place identifier.

Transform a placekey identifier to the equivalent H3 index.

#### ISVALID

{{% bannerNote type="code" %}}
placekey.ISVALID(placekey STRING) -> BOOLEAN
{{%/ bannerNote %}}

* `placekey`: `STRING` Place identifier.

Returns whether a given string represents a valid H3 index.

#### VERSION

{{% bannerNote type="code" %}}
placekey.VERSION() -> STRING
{{%/ bannerNote %}}

Returns the current version of the placekey library.