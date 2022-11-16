# Changelog

CARTO Analytics Toolbox Core for BigQuery.

All notable changes to this project will be documented in this file.

The format is inspired by [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### All modules

#### Changed

- Adapt to Semver

## [2022.11.08] - 2022-11-08

### Module h3

#### Changed

- Add linestrings and points support to function H3_POLYFILL.

## [2022.10.28] - 2022-10-28

### Module s2

#### Added

- Add S2_RESOLUTION function.
- Add S2_TOCHILDREN function.

## [2022.10.28] - 2022-10-26

### Module transformations

#### Fixed

- Fix ST_BUFFER crashing with geographies close to the poles.

## [2022.10.24] - 2022-10-24

### Module processing

#### Fixed

- Prevent error in ST_VORONOIPOLYGONS, ST_VORONOILINES, ST_VORONOIPOLYGONS, ST_DELAUNAYLINES when points where too close together by rounding input coordinates to 5 decimal places.

## [2022.10.07] - 2022-10-07

### Module clustering

#### Added

- Move ST_CLUSTERKMEANS function to core.

### Module random

#### Added

- Move ST_GENERATEPOINTS function to core.

## [2022.09.15] - 2022-09-15

### Module s2

#### Added

- Add S2_CENTER function.

## [2022.08.09] - 2022-08-09

### Module h3

#### Fixed

- Apply make_valid in H3_BOUNDARY.

## [2022.07.07] - 2022-07-07

### Module h3

#### Fixed

- Correctly handle large polygons in H3_POLYFILL.
- Fixed wrong uppercase for quadbin and h3 tile ids

## [2022.06.23] - 2022-06-23

### Module quadbin

#### Added

- Add QUADBIN_BBOX function.
- Add QUADBIN_BOUNDARY function.
- Add QUADBIN_CENTER function.
- Add QUADBIN_FROMGEOGPOINT function.
- Add QUADBIN_FROMLONGLAT function.
- Add QUADBIN_FROMZXY function.
- Add QUADBIN_ISVALID function.
- Add QUADBIN_KRING function.
- Add QUADBIN_KRING_DISTANCES function.
- Add QUADBIN_POLYFILL function.
- Add QUADBIN_RESOLUTION function.
- Add QUADBIN_SIBLING function.
- Add QUADBIN_TOCHILDREN function.
- Add QUADBIN_TOPARENT function.
- Add QUADBIN_TOZXY function.

## [2022.03.21] - 2022-03-21

### Module transformations

#### Changed

- ST_CONCAVEHULL now allows arrays with one/two points as input.

## [2022.02.15] - 2022-02-15

### Module h3

#### Added

- Add H3_CENTER function.
- Add H3_RESOLUTION function.

## [2021.12.16] - 2021-12-16

### Module accessors

#### Changed

- Deployment schema "carto" instead of "accessors".

#### Removed

- Remove VERSION function.

### Module constructors

#### Changed

- Deployment schema "carto" instead of "constructors".

#### Removed

- Remove VERSION function.

### Module geohash

#### Changed

- Deployment schema "carto" instead of "geohash".

#### Removed

- Remove VERSION function.

### Module h3

#### Changed

- Deployment schema "carto" instead of "h3".
- Rename ST_ASH3 function to H3_FROMGEOGPOINT.
- Rename LONGLAT_ASH3 function to H3_FROMLONGLAT.
- Rename ST_ASH3_POLYFILL function to H3_POLYFILL.
- Rename ST_BOUNDARY function to H3_BOUNDARY.
- Rename ISVALID function to H3_ISVALID.
- Rename COMPACT function to H3_COMPACT.
- Rename UNCOMPACT function to H3_UNCOMPACT.
- Rename TOPARENT function to H3_TOPARENT.
- Rename TOCHILDREN function to H3_TOCHILDREN.
- Rename ISPENTAGON function to H3_ISPENTAGON.
- Rename DISTANCE function to H3_DISTANCE.
- Rename KRING function to H3_KRING.
- Rename KRING_DISTANCES function to H3_KRING_DISTANCES.
- Rename HEXRING function to H3_HEXRING.

#### Removed

- Remove VERSION function.

### Module measurements

#### Changed

- Deployment schema "carto" instead of "measurements".

#### Removed

- Remove ST_ANGLE, already present in Bigquery.
- Remove VERSION function.

### Module placekey

#### Changed

- Deployment schema "carto" instead of "placekey".
- Rename H3_ASPLACEKEY function to PLACEKEY_FROMH3.
- Rename PLACEKEY_ASH3 function to PLACEKEY_TOH3.
- Rename ISVALID function to PLACEKEY_ISVALID.

#### Removed

- Remove VERSION function.

### Module processing

#### Changed

- Deployment schema "carto" instead of "processing".

#### Removed

- Remove VERSION function.

### Module s2

#### Changed

- Deployment schema "carto" instead of "s2".
- Rename ID_FROMHILBERTQUADKEY function to S2_FROMHILBERTQUADKEY.
- Rename HILBERTQUADKEY_FROMID function to S2_TOHILBERTQUADKEY.
- Rename LONGLAT_ASID function to S2_FROMLONGLAT.
- Rename ST_ASID function to S2_FROMGEOGPOINT.
- Rename ID_FROMTOKEN function to S2_FROMTOKEN.
- Rename TOKEN_FROMID function to S2_TOTOKEN.
- Rename ID_FROMUINT64REPR function to S2_FROMUINT64REPR.
- Rename UINT64REPR_FROMID function to S2_TOUINT64REPR.
- Rename ST_BOUNDARY function to S2_BOUNDARY.

#### Removed

- Remove VERSION function.

### Module transformations

#### Changed

- Deployment schema "carto" instead of "transformations".

#### Removed

- Remove VERSION function.

## [2021.09.23] - 2021-09-23

### Module s2

#### Changed

- Rename functions ID_FROMUINT64REPR, UINT64REPR_FROMID to follow convention.

## [2021.09.22] - 2021-09-22

### Module h3

#### Changed

- Review HEXRING, KRING functions.
- Change KRING_INDEXED to KRING_DISTANCES.

## [2021.09.14] - 2021-09-14

### Module s2

#### Fixed

- Avoid keeping planar shape in spherical coordinates in ST_BOUNDARY.

## [2021.08.24] - 2021-08-24

### Module h3

#### Fixed

- Support GEOMETRYCOLLECTION from ST_ASH3_POLYFILL.

## [2021.08.04] - 2021-08-04

### Module h3

#### Added

- Add KRING_INDEXED function.

## [2021.07.30] - 2021-07-30

### Module geohash

#### Added

- Create geohash module.
- Add VERSION function.
- Add ST_BOUNDARY function.

## [2021.06.01] - 2021-06-01

### Module s2

#### Added

- Add TOKEN_FROMID function.
- Add ID_FROMTOKEN function.
- Add ID_FROM_UINT64REPR function.
- Add UINT64REPR_FROM_ID function.

## [2021.05.04] - 2021-05-04

### Module accessors

#### Added

- Create accessors module.
- Add ST_ENVELOPE function.
- Add VERSION function.

### Module processing

#### Added

- Create processing module.
- Add ST_VORONOIPOLYGONS function.
- Add ST_VORONOILINES function.
- Add ST_DELAUNAYPOLYGONS function.
- Add ST_DELAUNAYLINES function.
- Add ST_POLYGONIZE function.
- Add VERSION function.

### Module transformations

#### Added

- Add ST_CONCAVEHULL function.

## [2021.04.29] - 2021-04-29

### Module constructors

#### Added

- Add ST_BEZIERSPLINE function.
- Add ST_MAKEELLIPSE function.

### Module measurements

#### Added

- Create measurements module.
- Add ST_ANGLE function.
- Add ST_AZIMUTH function.
- Add ST_MINKOWSKIDISTANCE function.

### Module transformations

#### Added

- Rename module to transformations.
- Add ST_CENTERMEAN function.
- Add ST_CENTERMEDIAN function.
- Add ST_CENTEROFMASS function.
- Add ST_DESTINATION function.
- Add ST_GREATCIRCLE function.
- Add ST_LINE_INTERPOLATE_POINT function.

## [2021.04.28] - 2021-04-28

### Module constructors

#### Added

- Create constructors module.
- Add ST_MAKEENVELOPE function.
- Add ST_TILEENVELOPE function.
- Add VERSION function.

## [2021.04.16] - 2021-04-16

### Module transformations

#### Added

- Create transformation module.
- Add ST_BUFFER function.
- Add VERSION function.

## [2021.04.09] - 2021-04-09

### Module h3

#### Changed

- Use hexadecimal as default type instead of int for h3 indexes.

#### Fixed

- Fix ST_BOUNDARY generating error when not able to parse geometry.

### Module placekey

#### Changed

- Placekey conversions works with hexadecimal h3 indexes instead of int.

## [2021.03.31] - 2021-03-31

### Module h3

#### Added

- Create h3 module.
- Add ST_ASH3 function.
- Add LONGLAT_ASH3 function.
- Add ST_ASH3_POLYFILL function.
- Add ST_BOUNDARY function.
- Add ISVALID function.
- Add COMPACT function.
- Add UNCOMPACT function.
- Add TOPARENT function.
- Add TOCHILDREN function.
- Add ISPENTAGON function.
- Add DISTANCE function.
- Add KRING function.
- Add HEXRING function.
- Add VERSION function.

### Module placekey

#### Added

- Create placekey module.
- Add H3_ASPLACEKEY function.
- Add PLACEKEY_ASH3 function.
- Add ISVALID function.
- Add VERSION function.

### Module s2

#### Added

- Create s2 module.
- Add ID_FROMHILBERTQUADKEY function.
- Add HILBERTQUADKEY_FROMID function.
- Add LONGLAT_ASID function.
- Add ST_ASID function.
- Add ST_BOUNDARY function.
- Add VERSION function.
