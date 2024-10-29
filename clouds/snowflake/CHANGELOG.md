# Changelog

CARTO Analytics Toolbox Core for Snowflake.

All notable commits to this project will be documented in this file.

## [1.2.6] - 2024-10-28

- chore(h3,quadbin): added "geo" aliases for certain functions (#526)

## [1.2.5] - 2024-09-23

- feat: added warehouse option for SF (#524)
- docs: add docs on how to update the analytics toolbox from a native app (#527)
- chore: update python version on stored procedures from 3.8 to 3.9 (#528)

## [1.2.4] - 2024-06-27

- chore: refactor at snowflake native app to an installer (#512)

## [1.2.3] - 2024-05-21

- refactor(h3): avoid memory limit exceeded in H3_POLYFILL_TABLE (#501)

## [1.2.2] - 2024-04-18

- chore(h3): reimplement basic h3 functions (#489)
- docs(processing): update voronoi doc (#492)
- chore(h3): reimplement polyfill h3 functions (#490)
- fix(clustering): improve how ST_CLUSTERKMEANS deals with duplicates (#491, #495)

## [1.2.1] - 2024-02-15

- chore: add additional tables to native apps (#473)
- fix(quadbin): QUADBIN_TOPARENT not working with views (#476)
- fix(random): ST_GENERATEPOINTS was not accepting column names (#480)

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
