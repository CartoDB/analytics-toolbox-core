----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

USE role ACCOUNTADMIN;
USE @@SF_DATABASE@@;

CREATE SHARE IF NOT EXISTS @@SF_SHARE@@;
grant usage on database @@SF_DATABASE@@ to share @@SF_SHARE@@;
grant usage on schema @@SF_PREFIX@@carto to share @@SF_SHARE@@;

grant usage on function QUADINT_BBOX(BIGINT) to share @@SF_SHARE@@;
grant usage on function QUADINT_TOCHILDREN(BIGINT,INT) to share @@SF_SHARE@@;
grant usage on function QUADINT_KRING(BIGINT,INT) to share @@SF_SHARE@@;
grant usage on function QUADINT_TOPARENT(BIGINT,INT) to share @@SF_SHARE@@;
grant usage on function QUADINT_FROMZXY(INT,INT,INT) to share @@SF_SHARE@@;
grant usage on function QUADINT_TOZXY(BIGINT) to share @@SF_SHARE@@;
grant usage on function QUADINT_FROMQUADKEY(STRING) to share @@SF_SHARE@@;
grant usage on function QUADINT_TOQUADKEY(BIGINT) to share @@SF_SHARE@@;
grant usage on function QUADINT_SIBLING(BIGINT,STRING) to share @@SF_SHARE@@;
grant usage on function QUADINT_FROMLONGLAT(DOUBLE,DOUBLE,INT) to share @@SF_SHARE@@;
grant usage on function QUADINT_FROMGEOGPOINT(GEOGRAPHY,INT) to share @@SF_SHARE@@;
grant usage on function QUADINT_POLYFILL(GEOGRAPHY,INT) to share @@SF_SHARE@@;
grant usage on function QUADINT_BOUNDARY(BIGINT) to share @@SF_SHARE@@;