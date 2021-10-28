----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

USE role ACCOUNTADMIN;
USE @@SF_DATABASE@@;

CREATE SHARE IF NOT EXISTS @@SF_SHARE@@;
grant usage on database @@SF_DATABASE@@ to share @@SF_SHARE@@;
grant usage on schema @@SF_DATABASE@@.@@SF_SCHEMA@@ to share @@SF_SHARE@@;

grant usage on function ST_VORONOIPOLYGONS(ARRAY, ARRAY) to share @@SF_SHARE@@;
grant usage on function ST_VORONOIPOLYGONS(ARRAY) to share @@SF_SHARE@@;
grant usage on function ST_VORONOILINES(ARRAY, ARRAY) to share @@SF_SHARE@@;
grant usage on function ST_VORONOILINES(ARRAY) to share @@SF_SHARE@@;
grant usage on function ST_DELAUNAYPOLYGONS(ARRAY) to share @@SF_SHARE@@;
grant usage on function ST_DELAUNAYLINES(ARRAY) to share @@SF_SHARE@@;
grant usage on function ST_POLYGONIZE(ARRAY) to share @@SF_SHARE@@;