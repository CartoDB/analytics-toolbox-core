----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

USE @@SF_DATABASE@@;

CREATE SHARE IF NOT EXISTS @@SF_SHARE_PUBLIC@@;
grant usage on database @@SF_DATABASE@@ to share @@SF_SHARE_PUBLIC@@;
grant usage on schema @@SF_DATABASE@@.@@SF_SCHEMA@@ to share @@SF_SHARE_PUBLIC@@;

grant usage on function @@SF_PREFIX@@processing.VERSION() to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@processing.ST_VORONOIPOLYGONS(ARRAY, ARRAY) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@processing.ST_VORONOIPOLYGONS(ARRAY) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@processing.ST_VORONOILINES(ARRAY, ARRAY) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@processing.ST_VORONOILINES(ARRAY) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@processing.ST_DELAUNAYPOLYGONS(ARRAY) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@processing.ST_DELAUNAYLINES(ARRAY) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@processing.ST_POLYGONIZE(ARRAY) to share @@SF_SHARE_PUBLIC@@;