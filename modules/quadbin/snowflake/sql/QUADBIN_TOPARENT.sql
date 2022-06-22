----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_TOPARENT
(quadbin INT, resolution INT)
RETURNS INT
AS $$
    SELECT bitand(
                bitand(
                    quadbin, 
                    bitor(
                        bitnot(bitshiftleft(31, 58)), 
                        bitshiftleft(resolution, 58)
                    )
                ), 
                bitshiftleft(
                    bitshiftleft(1, (5 + resolution * 2)) - 1, 
                    (58 - resolution * 2)
                )
            )
$$;