# Changelog

CARTO Analytics Toolbox Core for Redshift.

All notable commits to this project will be documented in this file.

## [1.1.3] - 2025-04-30

- chore(clustering): ST_CLUSTERKMEANS procedure throwing error for null geoms (#550)
- fix: set autocommit in run_query function (#552)

## [1.1.2] - 2024-10-28

- chore(h3,quadbin): added "geo" aliases for certain functions (#526)

## [1.1.1] - 2024-04-18

- docs(processing): update voronoi doc (#492)
- fix(clustering): improve how ST_CLUSTERKMEANS deals with duplicates (#491, #495)

## [1.1.0] - 2024-01-17

- feat(quadbin): add function QUADBIN_DISTANCE (#457)
- chore: fix naming dedicated deployments for releases (#462)
- fix(constructors,transformations): adjust SRID and use native ST_GEOMFROMGEOJSON to return geometries instead of VARCHAR (#463)
- chore: make remove drop functions instead of whole schema (#466)
- fix(quadbin): improve precision of long lat conversion near the latitude limits (#461)

## [1.0.2] - 2023-07-11

- chore(quadbin): update QUADBIN_FROMLONGLAT formula (#409, #411)
- chore(quadbin): optimize QUADBIN_TOCHILDREN performance (#412, #413)

## [1.0.1] - 2023-03-06

- chore: add initial version of cat-installer script (#386)
- fix(transformations): great circle crashing for equal origin and end (#390)

## [1.0.0] - 2023-01-30

- docs: adapted docs to gitbook (#380)
- docs: remove additional examples from the reference (#382)

## [0.2.0] - 2022-12-27

- feat(quadbin): add quadbin/quadkey conversion functions (#370)
