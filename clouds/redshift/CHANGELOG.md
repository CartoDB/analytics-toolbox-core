# Changelog

CARTO Analytics Toolbox Core for Redshift.

All notable changes to this project will be documented in this file.

The format is inspired by [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### All modules

#### New

- Create release workflows

#### Improvement

- Adapt to Semver

## [2022.10.07] - 2022-10-07

### Module clustering

#### New

- Move ST_CLUSTERKMEANS function to core.
- Move CREATE_CLUSTERKMEANS procedure to core.

### Module random

#### New

- Move ST_GENERATEPOINTS function to core.

## [2022.08.19] - 2022-08-19

### Module s2

#### Fix

- Fix S2_BOUNDARY inverted coordinates.

## [2022.07.14] - 2022-07-14

### Module quadbin

#### Improvement

- Update functions volatility.
- QUADBIN_FROMZXY accepting BIGINTs as params instead of INTs.

## [2022.07.08] - 2022-07-08

### Module quadbin

#### Improvement

- Release SQL version of QUADBIN_TOZXY.

## [2022.06.24] - 2022-06-24

### Module quadbin

#### New

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

## [2021.12.16] - 2021-12-16

### Module transformations

#### Fix

- Refactor of internal __ST_GEOMFROMGEOJSON function to avoid UDFs nestig Redshift limitations

## [2021.12.10] - 2021-12-10

### Module constructors

#### Improvement

- Deployment schema "carto" instead of "constructors".

#### Removed

- Remove VERSION function.

### Module placekey

#### Improvement

- Deployment schema "carto" instead of "placekey".
- Rename H3_ASPLACEKEY function to PLACEKEY_FROMH3.
- Rename PLACEKEY_ASH3 function to PLACEKEY_TOH3.
- Rename ISVALID function to PLACEKEY_ISVALID.

#### Removed

- Remove VERSION function.

### Module processing

#### Improvement

- Deployment schema "carto" instead of "processing".

#### Removed

- Remove VERSION function.

### Module s2

#### Improvement

- Deployment schema "carto" instead of "s2".
- Rename HILBERTQUADKEY_FROMID function to S2_TOHILBERTQUADKEY.
- Rename ID_FROMHILBERTQUADKEY function to S2_FROMHILBERTQUADKEY.
- Rename ID_FROMTOKEN function to S2_FROMTOKEN.
- Rename ID_FROMUINT64REPR function to S2_FROMUINT64REPR.
- Rename LONGLAT_ASID function to S2_FROMLONGLAT.
- Rename RESOLUTION function to S2_RESOLUTION.
- Rename ST_ASID function to S2_FROMGEOGPOINT.
- Rename ST_ASID_POLYFILL_BBOX function to S2_POLYFILL_BBOX.
- Rename ST_BOUNDARY function to S2_BOUNDARY.
- Rename TOCHILDREN function to S2_TOCHILDREN.
- Rename TOKEN_FROMID function to S2_TOTOKEN.
- Rename TOPARENT function to S2_TOPARENT.
- Rename UINT64REPR_FROMID function to S2_TOUINT64REPR.

#### Removed

- Remove VERSION function.

### Module transformations

#### Improvement

- Deployment schema "carto" instead of "transformations".

#### Removed

- Remove VERSION function.

## [2021.10.06] - 2021-10-06

### Module processing

#### New

- Create processing module.
- Add VERSION function.
- Add ST_POLYGONIZE function.
- Add ST_DELAUNAYLINES function.
- Add ST_DELAUNAYPOLYGONS function.
- Add ST_VORONOILINES function.
- Add ST_VORONOIPOLYGONS function.

### Module transformations

#### New

- Create transformations module.
- Add VERSION function.
- Add ST_CENTERMEAN function.
- Add ST_CENTROID function.
- Add ST_CENTEROFMASS function
- Add ST_CENTERMEDIAN function
- Add ST_GREATCIRCLE function
- Add ST_DESTINATION function

## [2021.09.23] - 2021-09-23

### Module s2

#### New

- Create s2 module.
- Add HILBERTQUADKEY_FROMID function.
- Add ID_FROMHILBERTQUADKEY function.
- Add ID_FROMTOKEN function.
- Add ID_FROMUINT64REPR function.
- Add LONGLAT_ASID function.
- Add RESOLUTION function.
- Add ST_ASID function.
- Add ST_ASID_POLYFILL_BBOX function.
- Add ST_BOUNDARY function.
- Add TOCHILDREN function.
- Add TOKEN_FROMID function.
- Add TOPARENT function.
- Add UINT64REPR_FROMID function.
- Add VERSION function.

## [2021.09.17] - 2021-09-17

### Module constructors

#### New

- Create constructors module.
- Add ST_BEZIERSPLINE function.
- Add ST_MAKEELLIPSE function.
- Add ST_MAKEENVELOPE function.
- Add ST_TILEENVELOPE function.
- Add VERSION function.

## [2021.09.07] - 2021-09-07

### Module placekey

#### New

- Create placekey module.
- Add H3_ASPLACEKEY function.
- Add PLACEKEY_ASH3 function.
- Add ISVALID function.
- Add VERSION function.
