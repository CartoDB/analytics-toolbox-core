--------------------------------
-- Copyright (C) 2022-2023 CARTO
--------------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.QUADBIN_TOPARENT
(quadbin BIGINT, resolution INT)
RETURNS BIGINT
IMMUTABLE
AS $$
    IFF(quadbin IS NULL OR resolution IS NULL OR resolution < 0 OR resolution > 26,
        NULL,
        bitor(
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
    )
$$;
