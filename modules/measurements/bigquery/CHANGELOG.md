# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2021-12-10

### Changed
- Deployment schema "carto" instead of "measurements".

#### Removed
- Remove ST_ANGLE, already present in Bigquery.
- Remove VERSION function.

## [1.0.0] - 2021-04-29

### Added
- Create measurements module.
- Add ST_ANGLE function.
- Add ST_AZIMUTH function.
- Add ST_MINKOWSKIDISTANCE function.