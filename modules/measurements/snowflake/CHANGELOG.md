# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.1.0] - 2021-12-03

### Changed
- Deployment schema "carto" instead of "measurements".

#### Removed
- Remove ST_ANGLE, already present in Snowflake.
- Remove ST_AZIMUTH, already present in Snowflake.
- Remove VERSION function.

## [1.0.0] - 2021-05-20

### Added
- Create measurements module.
- Add ST_ANGLE function.
- Add ST_AZIMUTH function.
- Add ST_MINKOWSKIDISTANCE function.
- Add VERSION function.