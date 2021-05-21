----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

USE @@SF_DATABASE@@;

CREATE SHARE IF NOT EXISTS @@SF_SHARE@@;
grant usage on database @@SF_DATABASE@@ to share @@SF_SHARE@@;
grant usage on schema @@SF_DATABASE@@.@@SF_SCHEMA@@ to share @@SF_SHARE@@;

grant usage on function @@SF_PREFIX@@placekey.H3_ASPLACEKEY(STRING) to share @@SF_SHARE@@;
grant usage on function @@SF_PREFIX@@placekey.PLACEKEY_ASH3(STRING) to share @@SF_SHARE@@;
grant usage on function @@SF_PREFIX@@placekey.ISVALID(STRING) to share @@SF_SHARE@@;
grant usage on function @@SF_PREFIX@@placekey.VERSION() to share @@SF_SHARE@@;