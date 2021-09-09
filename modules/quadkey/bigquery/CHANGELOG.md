# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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