# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.1.1] - 2022-01-07

### Fixed
- Fixed QUADINT_KRING
- Fixed QUADINT_KRING_DISTANCES
- Fixed QUADINT_SIBLING

### Added
- Add QUADINT_CENTER
- Add QUADINT_RESOLUTION

## [1.1.0] - 2021-12-16

### Changed
- Deployment schema "carto" instead of "quadkey".
- Rename ZXY_FROMQUADINT function to QUADINT_TOZXY.
- Rename LONGLAT_ASQUADINT function to QUADINT_FROMLONGLAT.
- Rename LONGLAT_ASQUADINTLIST_RESOLUTION function to QUADINT_FROMLONGLAT_ZOOMRANGE.
- Rename QUADKEY_FROMQUADINT function to QUADINT_TOQUADKEY.
- Rename TOPARENT function to QUADINT_TOPARENT.
- Rename TOCHILDREN function to QUADINT_TOCHILDREN.
- Rename SIBLING function to QUADINT_SIBLING.
- Rename KRING function to QUADINT_KRING.
- Rename KRING_DISTANCES function to QUADINT_KRING_DISTANCES.
- Rename BBOX function to QUADINT_BBOX.
- Rename ST_ASQUADINT function to QUADINT_FROMGEOGPOINT.
- Rename ST_ASQUADINT_POLYFILL function to QUADINT_POLYFILL.
- Rename ST_BOUNDARY function to QUADINT_BOUNDARY.

### Removed
- Remove VERSION function.

## [1.0.6] - 2021-10-01

### fixed
- Fix ST_BOUNDARY for level 1 and 2.

## [1.0.5] - 2021-09-22

### Changed
- Review KRING function.
- Change KRING_INDEXED to KRING_DISTANCES.

## [1.0.4] - 2021-09-09

### Changed
- Performance improvement in ST_ASQUADINT_POLYFILL.

## [1.0.3] - 2021-08-11

### Fixed
- Support GEOMETRYCOLLECTION from ST_ASQUADINT_POLYFILL.

## [1.0.2] - 2021-08-04

### Added
- Add KRING_INDEXED function.
- Add ST_GEOGPOINTFROMQUADINT function.

## [1.0.1] - 2021-04-16

### Changed
- Changed TOPARENT implementation to pure SQL.

## [1.0.0] - 2021-03-31

### Added
- Create quadkey module.
- Add QUADINT_FROMZXY function.
- Add ZXY_FROMQUADINT function.
- Add LONGLAT_ASQUADINT function.
- Add QUADINT_FROMQUADKEY function.
- Add QUADKEY_FROMQUADINT function.
- Add TOPARENT function.
- Add TOCHILDREN function.
- Add SIBLING function.
- Add KRING function.
- Add BBOX function.
- Add ST_ASQUADINT function.
- Add ST_ASQUADINT_POLYFILL function.
- Add ST_BOUNDARY function.
- Add LONGLAT_ASQUADINTLIST_RESOLUTION function.
- Add VERSION function.
