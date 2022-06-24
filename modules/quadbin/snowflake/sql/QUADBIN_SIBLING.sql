----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_SIBLING
(quadbin BIGINT, direction STRING)
RETURNS INT
IMMUTABLE
AS $$
  (WITH _dxy AS (
    SELECT CASE direction
        WHEN 'left' THEN
            OBJECT_CONSTRUCT('x', -1, 'y', 0)
        WHEN 'right' THEN
            OBJECT_CONSTRUCT('x', 1, 'y', 0)
        WHEN 'up' THEN
            OBJECT_CONSTRUCT('x', 0, 'y', -1)
        WHEN 'down' THEN
            OBJECT_CONSTRUCT('x', 0, 'y', 1)
        ELSE
            NULL
    END AS d,
  OBJECT_CONSTRUCT(
    'z',
    BITAND(BITSHIFTRIGHT(quadbin, 52), 31),
    'x',
    BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITOR(BITAND(BITOR(BITAND(BITOR(BITAND(BITOR(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), 1)),3689348814741910323), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), 1)),3689348814741910323), 2)),1085102592571150095), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITOR(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), 1)),3689348814741910323), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), 1)),3689348814741910323), 2)),1085102592571150095), 4)),71777214294589695), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITOR(BITAND(BITOR(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), 1)),3689348814741910323), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), 1)),3689348814741910323), 2)),1085102592571150095), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITOR(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), 1)),3689348814741910323), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), 1)),3689348814741910323), 2)),1085102592571150095), 4)),71777214294589695), 8)),281470681808895), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITOR(BITAND(BITOR(BITAND(BITOR(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), 1)),3689348814741910323), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), 1)),3689348814741910323), 2)),1085102592571150095), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITOR(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), 1)),3689348814741910323), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), 1)),3689348814741910323), 2)),1085102592571150095), 4)),71777214294589695), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITOR(BITAND(BITOR(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), 1)),3689348814741910323), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), 1)),3689348814741910323), 2)),1085102592571150095), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITOR(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), 1)),3689348814741910323), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12),6148914691236517205), 1)),3689348814741910323), 2)),1085102592571150095), 4)),71777214294589695), 8)),281470681808895), 16)),4294967295), (32 - BITAND(BITSHIFTRIGHT(quadbin, 52), 31))),
    'y',
    BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITOR(BITAND(BITOR(BITAND(BITOR(BITAND(BITOR(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), 1)),3689348814741910323), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), 1)),3689348814741910323), 2)),1085102592571150095), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITOR(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), 1)),3689348814741910323), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), 1)),3689348814741910323), 2)),1085102592571150095), 4)),71777214294589695), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITOR(BITAND(BITOR(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), 1)),3689348814741910323), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), 1)),3689348814741910323), 2)),1085102592571150095), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITOR(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), 1)),3689348814741910323), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), 1)),3689348814741910323), 2)),1085102592571150095), 4)),71777214294589695), 8)),281470681808895), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITOR(BITAND(BITOR(BITAND(BITOR(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), 1)),3689348814741910323), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), 1)),3689348814741910323), 2)),1085102592571150095), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITOR(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), 1)),3689348814741910323), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), 1)),3689348814741910323), 2)),1085102592571150095), 4)),71777214294589695), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITOR(BITAND(BITOR(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), 1)),3689348814741910323), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), 1)),3689348814741910323), 2)),1085102592571150095), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITOR(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), 1)),3689348814741910323), BITSHIFTRIGHT(BITAND(BITOR(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), BITSHIFTRIGHT(BITAND(BITSHIFTRIGHT(BITSHIFTLEFT(BITAND(quadbin,4503599627370495),12), 1),6148914691236517205), 1)),3689348814741910323), 2)),1085102592571150095), 4)),71777214294589695), 8)),281470681808895), 16)),4294967295), (32 - BITAND(BITSHIFTRIGHT(quadbin, 52), 31)))
  ) AS t
  )
  SELECT IFF(t:y + d:y >= 0 AND t:y + d:y < BITSHIFTLEFT(1, t:z),
        QUADBIN_FROMZXY(
            t:z,
            MOD(t:x + d:x, BITSHIFTLEFT(1, t:z)) + IFF(t:x + d:x < 0, BITSHIFTLEFT(1, t:z), 0),
            t:y + d:y
        ),
        NULL
    )
   FROM _dxy)
$$;

----------------------------
-- Original code:

-- CREATE OR REPLACE FUNCTION _QUADBIN_SIBLING
-- (origin INT, dx INT, dy INT)
-- RETURNS INT
-- AS $$
--     _ZXY_QUADBIN_SIBLING(
--         QUADBIN_TOZXY(origin), dx, dy
--     )
-- $$;