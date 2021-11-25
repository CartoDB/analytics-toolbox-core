# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2021-11-25

### Changed
- Deployment schema "carto" instead of "placekey".
- Rename H3_ASPLACEKEY function to PLACEKEY_FROMH3.
- Rename PLACEKEY_ASH3 function to PLACEKEY_TOH3.
- Rename ISVALID function to PLACEKEY_ISVALID.
- Remove VERSION function.

## [1.0.0] - 2021-04-16

### Added
- Create placekey module.
- Add H3_ASPLACEKEY function.
- Add PLACEKEY_ASH3 function.
- Add ISVALID function.
- Add VERSION function.