### ST_BITEARRAY

{{% bannerNote type="code" %}}
carto.ST_BITEARRAY(s)
{{%/ bannerNote %}}

**Description**

Encodes string _s_ into an array of bytes using the UTF-8 charset.

* `s`: `String` input geom win WKT format.

**Return type**

`Array[Byte]`

**Example**

```sql
SELECT ST_BYTEARRAY("POINT (-76.0913 18.4275)")
-- UE9JTlQgKC03Ni4wOTEzIDE4LjQyNzUp
```