# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2021-04-09

### Changed
* Use hexadecimal as default type instead of int for h3 indexes.

### Fixed
* Fix ST_BOUNDARY generating error when not able to parse geometry.

## [1.0.0] - 2021-03-31

### Added
* Initial implementation of the module, based on h3-js v3.7.0.