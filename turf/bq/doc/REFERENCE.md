## Reference

### TURF

This folder contains the structure so be used as base when adding new modules to the CARTO Spatial Extension.

#### Examples:

```
ST_BUFFER(geometry_to_buffer GEOGRAPHY, radius NUMERIC, units STRING, steps NUMERIC)
```
As taken from https://turfjs.org/docs/#buffer

``` sql
SELECT jslibs.turf.ST_BUFFER(ST_GEOGPOINT(-74.00,40.7128),1,'kilometers',10) as geo
```

#### turf.EXAMPLE_ADD

{{% bannerNote type="code" %}}
turf.EXAMPLE_ADD (value)
{{%/ bannerNote %}}

* `value`: `INT64` This is an example inlined code <code>\`projectID.dataset.tablename\`</code>.

Here is a tip:

{{% bannerNote type="note" title="tip"%}}
It's dangerous to go alone! Take this.
{{%/ bannerNote %}}


#### turf.VERSION

{{% bannerNote type="code" %}}
turf.VERSION()
{{%/ bannerNote %}}

Returns the current version of the turf library. Here is some sample code block:

```js
function turfExampleAdd(v) {
    return v + 1;
}
```

And a table:

| Column1 | Description |
| :----- | :------ |
|`taters`| Few and good. |
|`potatoes`| Boil 'em, mash 'em, stick 'em in a stew.|
|`chips`| Lovely big golden chips with a nice piece of fried fish.|
