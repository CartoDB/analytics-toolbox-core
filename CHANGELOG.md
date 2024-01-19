# Changelog

CARTO Analytics Toolbox Core.

All notable commits to this project will be documented in this file.

## 2024-01-17

- chore(bq): increase tests timeout to 200000 (#455)
- feat(bq,sf,rs,pg|quadbin): add function QUADBIN_DISTANCE (#457)
- fix(bq|h3): fix broken reference in H3_POLYFILL_TABLE (#458, #460)
- chore(bq,sf,rs,pg): fix naming dedicated deployments for releases (#462)
- fix(sf|quadbin): QUADBIN_FROMLONGLAT not clamping latitudes and return some quadbin functions return NULL when NULL parameters (#456)
- fix(rs|constructors,transformations): adjust SRID and use native ST_GEOMFROMGEOJSON to return geometries instead of VARCHAR (#463)
- chore(pg): fix typo naming dedicated deployments for releases (#464)
- chore(bq,sf,rs,pg): make remove drop functions instead of whole schema (#466)
- fix(bq,sf,rs,pg|quadbin): improve precision of long lat conversion near the latitude limits (#461)
- feat(bq,sf|transformations): add function ST_POINTONSURFACE (#469, #470)

## 2023-08-04

- chore(bq|quadbin,h3): optimize quadbin/h3 polyfill performance (#421)
- chore(pg|quadbin,h3): optimize quadbin/h3 polyfill performance (#418)
- feat(bq,pg|quadbin,h3): center as default mode in QUADBIN_POLYFILL and H3_POLYFILL (#439)
- docs(db): fixed return type in ST_RELATE example (#440)
- docs(sf): added example using array_agg for concave hull in SF (#437)

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
