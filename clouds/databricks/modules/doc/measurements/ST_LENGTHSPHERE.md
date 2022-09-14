### ST_LENGTHSPHERE

{{% bannerNote type="code" %}}
carto.ST_LENGTHSPHERE(line)
{{%/ bannerNote %}}

**Description**

Approximates the 2D path length of a `LineString` geometry using a spherical earth model. The returned length is in units of meters. The approximation is within 0.3% of st_lengthSpheroid and is computationally more efficient.

* `line`: `LineString` input line.

**Return type**

`Double`

**Example**

```sql
SELECT carto.ST_LENGTHSPHERE(carto.ST_GEOMFROMWKT('LINESTRING(0 0, 0 3, 5 3)')) / 1000;
-- 888.7982099954688 (distance in km)
```