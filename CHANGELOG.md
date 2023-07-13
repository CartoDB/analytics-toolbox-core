# Changelog

CARTO Analytics Toolbox Core.

All notable commits to this project will be documented in this file.

## 2023-07-11

- chore(bq,rs,pg|quadbin): update QUADBIN_FROMLONGLAT formula (#409, #411)
- chore(bq,rs,pg|quadbin): optimize QUADBIN_TOCHILDREN performance (#412, #413)
- chore(bq,sf,pg): introduce skip_progress_bar option to allow deploying faster (#416, #419)
- chore(all): use matrix in deploy internal and deploy in ci (#430, #433)
- fix(rs): update github actions to prevents python2 incompatibility (#431, #434)

## 2023-06-01

- fix(tools|installer): verify lds config when using cat-installer (#406)

## 2023-05-05

- feat(sf|h3): add H3_CENTER function (#395)
- feat(sf|transformations): add ST_CONVEXHULL function (#397)
- feat(pg|h3): support H3 functions (#396)
- feat(pg|tools): add cat-installer for pg (#400)
- fix(all|h3,quadbin,placekey,s2): update indexes in examples (#401)
- feat(sf|h3): add H3_RESOLUTION function (#402)

## 2023-03-06

- chore(rs): add initial version of cat-installer script (#386)
- docs: update reference links (#389)
- fix(bq,sf,rs|transformations): great circle crashing for equal origin and end (#390)

## 2023-01-30

- fix(bq,sf): use extended toBeCloseTo in tests (#381)
- docs: adapted docs to gitbook (#380)
- docs: remove additional examples from the reference (#382)

## 2022-12-27

- docs(bq,sf|h3): add H3 INT/STRING functions reference (#369)
- feat(bq,sf,rs,pg|quadbin): add quadbin/quadkey conversion functions (#370)
- fix(sf|h3): H3_BOUNDARY by removing duplicated points (#371)
- fix(sf): add missing SECURE tag to share ATC functions (#372)
