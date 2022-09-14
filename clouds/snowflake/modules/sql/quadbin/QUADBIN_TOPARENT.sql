----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@.QUADBIN_TOPARENT
(quadbin BIGINT, resolution INT)
RETURNS BIGINT
IMMUTABLE
AS $$
    SELECT bitor(
                bitor(
                    bitand(
                        quadbin,
                        bitnot(
                            bitshiftleft(31, 52)
                        )
                    ),
                    bitshiftleft(resolution, 52)
                ),
                bitshiftright(
                    4503599627370495,
                    resolution * 2
                )
            )
$$;
