# Changelog

CARTO Analytics Toolbox Core for Snowflake.

All notable commits to this project will be documented in this file.

## [1.2.0] - 2024-01-17

- feat(quadbin): add function QUADBIN_DISTANCE (#457)
- chore: fix naming dedicated deployments for releases (#462)
- fix(quadbin): QUADBIN_FROMLONGLAT not clamping latitudes and return some quadbin functions return NULL when NULL parameters (#456)
- chore: make remove drop functions instead of whole schema (#466)
- fix(quadbin): improve precision of long lat conversion near the latitude limits (#461)
- feat(transformations): add function ST_POINTONSURFACE (#470)

## [1.1.0] - 2023-05-05

- feat(h3): add H3_CENTER function (#395)
- feat(h3): add H3_RESOLUTION function (#402)
- feat(transformations): add ST_CONVEXHULL function (#397)

## [1.0.1] - 2023-03-06

- fix(transformations): great circle crashing for equal origin and end (#390)

## [1.0.0] - 2023-01-30

- fix: use extended toBeCloseTo in tests (#381)
- docs: adapted docs to gitbook (#380)
- docs: remove additional examples from the reference (#382)

## [0.2.0] - 2022-12-27

- docs(h3): add H3 INT/STRING functions reference (#369)
- feat(quadbin): add quadbin/quadkey conversion functions (#370)
- fix(h3): H3_BOUNDARY by removing duplicated points (#371)
- fix: add missing SECURE tag to share ATC functions (#372)
