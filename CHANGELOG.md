# Changelog

CARTO Analytics Toolbox Core.

All notable commits to this project will be documented in this file.

## 2025-11-26

- chore(sf): increase test timeout from 40000 to 50000 (#558)
- chore(sf): update node version (#559)
- chore(sf): allow slow tests in snowflake (#561)
- feat(db): Reimplement ATC/AT Databricks scaffolding [sc-512318] (#562)
- fix(sf): update turf version (#564)
- chore(db): update ci/cd env for databricks (#565)

## 2025-04-30

- chore(bq,sf,rs|clustering): ST_CLUSTERKMEANS procedure throwing error for null geoms (#550)
- fix(rs): set autocommit in run_query function (#552)
- chore: update deprecated ubuntu image for ci (#553)

## 2025-01-30

- chore(sf): deploy snowflake in CARTO.CARTO when releasing (#536)
- chore: update gh actions versions (#537)
- chore(bq): add skip dependency tag in bigquery build_modules (#538)
- docs(sf|h3): update h3_polyfill_table docs as it does not support points or lines (#539)
- chore(deps): bump jinja2 from 3.1.3 to 3.1.5 in /clouds/databricks/common (#540)
- fix(bq|h3,quadbin): H3_POLYFILL and QUADBIN_POLYFILL functions not working with holes (#542)
- chore(bq): split JS libraries generation (#541, #543)
- chore(sf): SF_ACCOUNT no longer follows "account.region" format (#544)

## 2024-10-28

- chore(bq): fix @google-cloud/bigquery to version 7.9.0 (#531)
- chore(bq,sf,rs,pg|h3,quadbin): added "geo" aliases for certain functions (#526)

## 2024-09-23

- feat(sf): added warehouse option for SF (#524)
- chore(bq): increse jest timeout to 30000 (#525)
- docs(sf): add docs on how to update the analytics toolbox from a native app (#527)
- chore(sf): update python version on stored procedures from 3.8 to 3.9 (#528)

## 2024-08-22

- chore(rs): bump scipy from 0.12.0 to 0.12.1 in /clouds/redshift/libraries/python (#518)
- docs(sf): fix native apps installation doc (#519)
- fix(pg): lock numpy to v1.24.4 until pandas supports 2.X.X (#520)

## 2024-06-27

- chore(sf): refactor at snowflake native app to an installer (#512)
- chore(bq|quadbin): optimize polyfill (#513)

## 2024-05-21

- refactor(sf|h3): avoid memory limit exceeded in H3_POLYFILL_TABLE (#501)
- docs(bq,sf,rs|constructors): fix ST_MAKEELLIPSE angle parameter explanation (#505)
- chore(sf): update create-package and licenses year (#507)
- chore(pg): DB Connection Error in tests when % character in PG_PASSWORD (#509)

## 2024-04-18

- chore(sf|h3): reimplement basic h3 functions (#489)
- docs(bq,sf,rs|processing): update voronoi doc (#492)
- chore(sf|h3): reimplement polyfill h3 functions (#490)
- fix(bq,sf,rs|clustering): improve how ST_CLUSTERKMEANS deals with duplicates (#491, #495)
- chore(deps): bump sqlparse from 0.4.4 to 0.5.0 in /clouds/redshift/common (#494)
- chore(deps): bump sqlparse from 0.4.4 to 0.5.0 in /clouds/postgres/common (#493)
- chore(deps): fix CI crashing because native-apps timeout and sql-parse version (#496)

## 2024-03-18

- fix(sf): CI and CD not working because of snowflake driver breaking changes (#484)
- fix(bq,sf,rs,pg): drop schemas when dedicateds gets released (#485)
- fix(bq|random): ST_GENERATEPOINTS returning exact name of points (#486)
- chore(rs,pg): remove installer tool (#483)
- chore(deps): bump jinja2 from 3.1.2 to 3.1.3 in /clouds/databricks/common (#468)

## 2024-02-15

- chore(sf): add additional tables to native apps (#473)
- docs(bs,sf,rs|transformations): fix ST_DESTINATION bearing parameter description (#475)
- fix(sf|quadbin): QUADBIN_TOPARENT not working with views (#476)
- docs(bq,sf,rs|constructors): fix angle parameter description in ST_MAKEELLIPSE (#477)
- fix(sf|random): ST_GENERATEPOINTS was not accepting column names (#480)

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
