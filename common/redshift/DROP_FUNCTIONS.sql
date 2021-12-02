CREATE OR REPLACE PROCEDURE @@RS_PREFIX@@carto.__create_drop_table
(schema_name varchar(max))
AS $$
DECLARE 
  row record;
BEGIN
  DROP TABLE IF EXISTS _udfs_info;
  --open cur refcursor;
  CREATE TEMP TABLE _udfs_info (f_oid bigint, f_kind varchar(1), f_name varchar(max), arg_index bigint, f_argtype varchar(max));
  FOR row IN SELECT oid::BIGINT f_oid, kind::VARCHAR(1) f_kind, proname::VARCHAR(MAX) f_name, i arg_index, format_type(arg_types[i-1], null)::VARCHAR(MAX) f_argtype
FROM (
  SELECT oid, kind, proname, generate_series(1, arg_count) AS i, arg_types
  FROM (SELECT p.prooid oid, p.prokind kind, proname, proargtypes arg_types, pronargs arg_count FROM
    pg_catalog.pg_namespace n
    JOIN
        PG_PROC_INFO p
    ON  pronamespace = n.oid
WHERE
    nspname = schema_name) t
) t
   LOOP
    INSERT INTO _udfs_info(f_oid, f_kind, f_name,arg_index,f_argtype) VALUES (row.f_oid, row.f_kind, row.f_name, row.arg_index, row.f_argtype);
  END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE @@RS_PREFIX@@carto.__drop_functions
(schema_name varchar(max))
AS $$
DECLARE
	row record;
BEGIN
	CALL @@RS_PREFIX@@carto.__create_drop_table(schema_name);

	FOR row IN SELECT drop_command
	FROM
	(
	SELECT 'DROP ' || CASE f_kind WHEN 'p' THEN 'PROCEDURE' ELSE 'FUNCTION' END || ' @@RS_PREFIX@@carto.' || f_name || '(' || listagg(f_argtype,',' ) WITHIN GROUP (ORDER BY arg_index) || ');' AS drop_command
	FROM _udfs_info
	GROUP BY f_oid, f_name, f_kind)
   	LOOP
		execute row.drop_command;
	END LOOP;

	DROP TABLE IF EXISTS _udfs_info;
END;
$$ LANGUAGE plpgsql;

CALL @@RS_PREFIX@@carto.__drop_functions('@@RS_PREFIX@@carto');