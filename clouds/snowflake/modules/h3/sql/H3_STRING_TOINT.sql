CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@.H3_STRING_TOINT
(
  h3 STRING
)
RETURNS INT
AS $$
  to_number(h3, 'xxxxxxxxxxxxxxx')
$$;