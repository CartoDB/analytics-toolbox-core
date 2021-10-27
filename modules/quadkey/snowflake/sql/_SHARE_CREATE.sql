----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

USE role ACCOUNTADMIN;
USE @@SF_DATABASE@@;

CREATE SHARE IF NOT EXISTS @@SF_SHARE@@;
grant usage on database @@SF_DATABASE@@ to share @@SF_SHARE@@;
grant usage on schema @@SF_PREFIX@@carto to share @@SF_SHARE@@;

grant usage on function BBOX(BIGINT) to share @@SF_SHARE@@;
grant usage on function TOCHILDREN(BIGINT,INT) to share @@SF_SHARE@@;
grant usage on function KRING(BIGINT,INT) to share @@SF_SHARE@@;
grant usage on function TOPARENT(BIGINT,INT) to share @@SF_SHARE@@;
grant usage on function QUADINT_FROMZXY(INT,INT,INT) to share @@SF_SHARE@@;
grant usage on function ZXY_FROMQUADINT(BIGINT) to share @@SF_SHARE@@;
grant usage on function QUADINT_FROMQUADKEY(STRING) to share @@SF_SHARE@@;
grant usage on function QUADKEY_FROMQUADINT(BIGINT) to share @@SF_SHARE@@;
grant usage on function SIBLING(BIGINT,STRING) to share @@SF_SHARE@@;
grant usage on function LONGLAT_ASQUADINT(DOUBLE,DOUBLE,INT) to share @@SF_SHARE@@;
grant usage on function ST_ASQUADINT(GEOGRAPHY,INT) to share @@SF_SHARE@@;
grant usage on function ST_ASQUADINT_POLYFILL(GEOGRAPHY,INT) to share @@SF_SHARE@@;
grant usage on function ST_BOUNDARY(BIGINT) to share @@SF_SHARE@@;
grant usage on function VERSION() to share @@SF_SHARE@@;