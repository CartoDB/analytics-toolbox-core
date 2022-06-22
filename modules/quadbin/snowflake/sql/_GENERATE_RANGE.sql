----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _GENERATE_ARRAY
(min INT, max INT)
RETURNS TABLE
AS $$
    WITH x (n) as (
        SELECT min 
        UNION ALL 
        SELECT (x.n + 1) n 
        FROM x WHERE x.n < max
    ) 
    select * from x
$$