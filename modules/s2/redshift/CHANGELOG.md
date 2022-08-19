# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.1.1] - 2022-08-19

### Fixed
- Fix S2_BOUNDARY inverted coordinates.

## [1.1.0] - 2021-12-10

### Changed
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

### Removed
- Remove VERSION function.

## [1.0.0] - 2021-09-23

### Added
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
