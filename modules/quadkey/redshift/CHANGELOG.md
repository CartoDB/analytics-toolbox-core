# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.1.1] - 2022-06-23

### Fixed
- Fix wrong distances in QUADINT_KRING_DISTANCES.
- Allow any input SRID in ST_ASQUADINT_POLYFILL

## [1.1.0] - 2021-12-10

### Changed
- Deployment schema "carto" instead of "quadkey".
- Rename ZXY_FROMQUADINT function to QUADINT_TOZXY.
- Rename LONGLAT_ASQUADINT function to QUADINT_FROMGEOGPOINT.
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

## [1.0.1] - 2021-09-22

### Added
- Add KRING_DISTANCES function.

### Changed
- Review KRING function.

## [1.0.0] - 2021-09-09

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
- Add VERSION function.