# Changelog

CARTO Analytics Toolbox Core for Postgres.

All notable commits to this project will be documented in this file.

## [1.3.1] - 2024-10-28

- chore(h3,quadbin): added "geo" aliases for certain functions (#526)

## [1.3.0] - 2024-01-17

- feat(quadbin): add function QUADBIN_DISTANCE (#457)
- chore: fix naming dedicated deployments for releases (#462)
- chore: fix typo naming dedicated deployments for releases (#464)
- chore: make remove drop functions instead of whole schema (#466)
- fix(quadbin): improve precision of long lat conversion near the latitude limits (#461)

## [1.2.0] - 2023-08-04

- chore(quadbin,h3): optimize quadbin/h3 polyfill performance (#418)
- feat(quadbin,h3): center as default mode in QUADBIN_POLYFILL and H3_POLYFILL (#439)

## [1.1.1] - 2023-07-11

- chore(quadbin): update QUADBIN_FROMLONGLAT formula (#409, #411)
- chore(quadbin): optimize QUADBIN_TOCHILDREN performance (#412, #413)

## [1.1.0] - 2023-05-05

- feat(h3): support H3 functions (#396)
- feat(tools): add cat-installer for pg (#400)

## [1.0.0] - 2023-01-30

- docs: adapted docs to gitbook (#380)
- docs: remove additional examples from the reference (#382)

## [0.2.0] - 2022-12-27

- feat(quadbin): add quadbin/quadkey conversion functions (#370)
