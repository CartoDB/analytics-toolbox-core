# Turf

Taken from here https://turfjs.org

As usual, the functions following the OGC naming standard uses as much as possible GEOGRAPHY as input

## Examples:

```
ST_BUFFER(geometry_to_buffer GEOGRAPHY, radius NUMERIC, units STRING, steps NUMERIC)
```
As taken from https://turfjs.org/docs/#buffer

``` sql
SELECT jslibs.turf.ST_BUFFER(ST_GEOGPOINT(-74.00,40.7128),1,'kilometers',10) as geo
```
