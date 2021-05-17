----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

USE @@SF_DATABASE@@;

CREATE SHARE IF NOT EXISTS @@SF_SHARE_PUBLIC@@;
grant usage on database @@SF_DATABASE@@ to share @@SF_SHARE_PUBLIC@@;
grant usage on schema @@SF_DATABASE@@.@@SF_SCHEMA@@ to share @@SF_SHARE_PUBLIC@@;

grant usage on function @@SF_PREFIX@@constructors.ST_BEZIERSPLINE(GEOGRAPHY) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@constructors.ST_BEZIERSPLINE(GEOGRAPHY, INT) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@constructors.ST_BEZIERSPLINE(GEOGRAPHY, INT, DOUBLE) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@constructors.ST_MAKEELLIPSE(GEOGRAPHY, DOUBLE, DOUBLE) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@constructors.ST_MAKEELLIPSE(GEOGRAPHY, DOUBLE, DOUBLE, DOUBLE) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@constructors.ST_MAKEELLIPSE(GEOGRAPHY, DOUBLE, DOUBLE, DOUBLE, STRING) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@constructors.ST_MAKEELLIPSE(GEOGRAPHY, DOUBLE, DOUBLE, DOUBLE, STRING, INT) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@constructors.ST_MAKEENVELOPE(DOUBLE, DOUBLE, DOUBLE, DOUBLE) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@constructors.ST_TILEENVELOPE(INT, INT, INT) to share @@SF_SHARE_PUBLIC@@;
grant usage on function @@SF_PREFIX@@constructors.VERSION() to share @@SF_SHARE_PUBLIC@@;