CREATE OR REPLACE FUNCTION H3_STRING_TOINT
(
  h3 STRING
)
RETURNS INT
AS $$
  to_number(h3, 'xxxxxxxxxxxxxxx')
$$;