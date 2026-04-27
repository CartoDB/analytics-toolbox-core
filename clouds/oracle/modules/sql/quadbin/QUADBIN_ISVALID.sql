----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Validates whether a given NUMBER is a valid quadbin index by checking
-- the header bit, mode, zoom level, and unused trailing bits.
--
-- Oracle bit operation equivalents:
--   a >> n  =>  TRUNC(a / POWER(2, n))
--   a & b   =>  BITAND(a, b)
--
-- Returns 1 if valid, 0 if invalid. Type is NUMBER(1), the Oracle convention
-- for a boolean (no native SQL BOOLEAN). Callers test with `= 1`.
--
-- Bit-mask constants (decimal equivalents):
--   HEADER_MASK = 4611686018427387904 = 0x4000000000000000
--   UNUSED_MASK = 4503599627370495    = 0xFFFFFFFFFFFFF

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_ISVALID
(quadbin NUMBER)
RETURN NUMBER
-- NUMBER(1) is the conventional boolean shape; the function is declared
-- as NUMBER (Oracle ignores precision/scale on PL/SQL function returns
-- but the contract is documented for callers and SQL clients).
AS
    HEADER_MASK  CONSTANT NUMBER := 4611686018427387904;
    UNUSED_MASK  CONSTANT NUMBER := 4503599627370495;
    MAX_MODE     CONSTANT NUMBER := 6;
    MAX_ZOOM     CONSTANT NUMBER := 26;
    MODE_WIDTH   CONSTANT NUMBER := 7;
    ZOOM_WIDTH   CONSTANT NUMBER := 31;

    v_mode_bits  NUMBER;
    v_zoom       NUMBER;
    v_unused     NUMBER;
BEGIN
    IF quadbin IS NULL OR quadbin < 0 THEN
        RETURN 0;
    END IF;

    -- Header bit check
    IF BITAND(quadbin, HEADER_MASK) != HEADER_MASK THEN
        RETURN 0;
    END IF;

    -- Mode bits (bits 59-61): must be in range 0-6
    v_mode_bits := BITAND(TRUNC(quadbin / POWER(2, 59)), MODE_WIDTH);
    IF v_mode_bits > MAX_MODE THEN
        RETURN 0;
    END IF;

    -- Zoom level (bits 52-56): must be in range 0-26
    v_zoom := BITAND(TRUNC(quadbin / POWER(2, 52)), ZOOM_WIDTH);
    IF v_zoom > MAX_ZOOM THEN
        RETURN 0;
    END IF;

    -- Unused trailing bits must match expected pattern
    v_unused := TRUNC(UNUSED_MASK / POWER(2, v_zoom * 2));
    IF BITAND(quadbin, v_unused) != v_unused THEN
        RETURN 0;
    END IF;

    RETURN 1;
END;
/
