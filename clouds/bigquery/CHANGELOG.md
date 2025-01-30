# Changelog

CARTO Analytics Toolbox Core for BigQuery.

All notable commits to this project will be documented in this file.

## [1.2.5] - 2025-01-30

- fix(h3,quadbin): H3_POLYFILL and QUADBIN_POLYFILL functions not working with holes (#542)

## [1.2.4] - 2024-10-28

- chore: fix @google-cloud/bigquery to version 7.9.0 (#531)
- chore(h3,quadbin): added "geo" aliases for certain functions (#526)

## [1.2.3] - 2024-06-27

- chore(quadbin): optimize polyfill (#513)

## [1.2.2] - 2024-04-18

- docs(processing): update voronoi doc (#492)
- fix(clustering): improve how ST_CLUSTERKMEANS deals with duplicates (#491, #495)

## [1.2.1] - 2024-03-18

- fix(random): ST_GENERATEPOINTS returning exact name of points (#486)

## [1.2.0] - 2024-01-17

- chore: increase tests timeout to 200000 (#455)
- feat(quadbin): add function QUADBIN_DISTANCE (#457)
- fix(h3): fix broken reference in H3_POLYFILL_TABLE (#458, #460)
- chore: fix naming dedicated deployments for releases (#462)
- chore: make remove drop functions instead of whole schema (#466)
- fix(quadbin): improve precision of long lat conversion near the latitude limits (#461)
- feat(transformations): add function ST_POINTONSURFACE (#469)

## [1.1.0] - 2023-08-04

- chore(quadbin,h3): optimize quadbin/h3 polyfill performance (#421)
- feat(quadbin,h3): center as default mode in QUADBIN_POLYFILL and H3_POLYFILL (#439)

## [1.0.2] - 2023-07-11

- chore(quadbin): update QUADBIN_FROMLONGLAT formula (#409, #411)
- chore(quadbin): optimize QUADBIN_TOCHILDREN performance (#412, #413)

## [1.0.1] - 2023-03-06

- fix(transformations): great circle crashing for equal origin and end (#390)

## [1.0.0] - 2023-01-30

- fix: use extended toBeCloseTo in tests (#381)
- docs: adapted docs to gitbook (#380)
- docs: remove additional examples from the reference (#382)

## [0.2.0] - 2022-12-27

- docs(h3): add H3 INT/STRING functions reference (#369)
- feat(quadbin): add quadbin/quadkey conversion functions (#370)
