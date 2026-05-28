----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- MLE module bundling the quadbin JavaScript library. The placeholder
-- @@ORA_LIBRARY_QUADBIN@@ is substituted at build time with the bundled
-- contents of libraries/javascript/build/quadbin.js (rollup output).
--
-- Build pipeline: libraries/javascript/Makefile produces build/quadbin.js
-- before this SQL is processed. build_modules.js detects the placeholder
-- and inlines the JS content.
--
-- Deploy ordering: build_modules.js dependency detection finds files that
-- reference `AS MLE MODULE quadbin_module` and orders them after this file.

CREATE OR REPLACE MLE MODULE @@ORA_SCHEMA@@.quadbin_module LANGUAGE JAVASCRIPT AS
@@ORA_LIBRARY_QUADBIN@@
/
