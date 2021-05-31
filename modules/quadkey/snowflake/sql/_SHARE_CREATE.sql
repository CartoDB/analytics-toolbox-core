----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

USE role ACCOUNTADMIN;
USE @@SF_DATABASE@@;

CREATE SHARE IF NOT EXISTS @@SF_SHARE@@;
grant usage on database @@SF_DATABASE@@ to share @@SF_SHARE@@;
grant usage on schema @@SF_PREFIX@@quadkey to share @@SF_SHARE@@;

grant usage on function @@SF_PREFIX@@quadkey.BBOX(BIGINT) to share @@SF_SHARE@@;
grant usage on function @@SF_PREFIX@@quadkey.TOCHILDREN(BIGINT,INT) to share @@SF_SHARE@@;
grant usage on function @@SF_PREFIX@@quadkey.KRING(BIGINT,INT) to share @@SF_SHARE@@;
grant usage on function @@SF_PREFIX@@quadkey.TOPARENT(BIGINT,INT) to share @@SF_SHARE@@;
grant usage on function @@SF_PREFIX@@quadkey.QUADINT_FROMZXY(INT,INT,INT) to share @@SF_SHARE@@;
grant usage on function @@SF_PREFIX@@quadkey.ZXY_FROMQUADINT(BIGINT) to share @@SF_SHARE@@;
grant usage on function @@SF_PREFIX@@quadkey.QUADINT_FROMQUADKEY(STRING) to share @@SF_SHARE@@;
grant usage on function @@SF_PREFIX@@quadkey.QUADKEY_FROMQUADINT(BIGINT) to share @@SF_SHARE@@;
grant usage on function @@SF_PREFIX@@quadkey.SIBLING(BIGINT,STRING) to share @@SF_SHARE@@;
grant usage on function @@SF_PREFIX@@quadkey.LONGLAT_ASQUADINT(DOUBLE,DOUBLE,INT) to share @@SF_SHARE@@;
grant usage on function @@SF_PREFIX@@quadkey.ST_ASQUADINT(GEOGRAPHY,INT) to share @@SF_SHARE@@;
grant usage on function @@SF_PREFIX@@quadkey.ST_ASQUADINT_POLYFILL(GEOGRAPHY,INT) to share @@SF_SHARE@@;
grant usage on function @@SF_PREFIX@@quadkey.ST_BOUNDARY(BIGINT) to share @@SF_SHARE@@;
grant usage on function @@SF_PREFIX@@quadkey.VERSION() to share @@SF_SHARE@@;