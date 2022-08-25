# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.2.2] - 2022-08-25

### Added
- Add S2_CENTER function.

## [1.2.0] - 2021-12-16

### Changed
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

### Removed
- Remove VERSION function.

## [1.1.2] - 2021-09-23

### Changed
- Rename functions ID_FROMUINT64REPR, UINT64REPR_FROMID to follow convention.

## [1.1.1] - 2021-09-14

### Fixed
- Avoid keeping planar shape in spherical coordinates in ST_BOUNDARY.

## [1.1.0] - 2021-06-01

### Added
- Add TOKEN_FROMID function.
- Add ID_FROMTOKEN function.
- Add ID_FROM_UINT64REPR function.
- Add UINT64REPR_FROM_ID function.

## [1.0.0] - 2021-03-31

### Added
- Create s2 module.
- Add ID_FROMHILBERTQUADKEY function.
- Add HILBERTQUADKEY_FROMID function.
- Add LONGLAT_ASID function.
- Add ST_ASID function.
- Add ST_BOUNDARY function.
- Add VERSION function.
