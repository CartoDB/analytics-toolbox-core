# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2021-11-25

### Changed
- Deployment schema "carto" instead of "s2".
- Rename ID_FROMHILBERTQUADKEY function to S2_IDFROMHILBERTQUADKEY.
- Rename HILBERTQUADKEY_FROMID function to S2_HILBERTQUADKEYFROMID.
- Rename LONGLAT_ASID function to S2_IDFROMLONGLAT.
- Rename ST_ASID function to S2_IDFROMGEOGPOINT.
- Rename ST_BOUNDARY function to S2_BOUNDARY.
- Remove VERSION function.

## [1.0.1] - 2021-09-14

### Changes
- Compute ST_BOUNDARY from WKT.

## [1.0.0] - 2021-04-12

### Added
- Create s2 module.
- Add ID_FROMHILBERTQUADKEY function.
- Add HILBERTQUADKEY_FROMID function.
- Add LONGLAT_ASID function.
- Add ST_ASID function.
- Add ST_BOUNDARY function.
- Add VERSION function.