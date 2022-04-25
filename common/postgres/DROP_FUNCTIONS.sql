SET search_path TO @@PG_PREFIX@@carto,public,"$user";

CREATE OR REPLACE PROCEDURE __DROP_FUNCTIONS
(schema_name TEXT)
AS $$
DECLARE
	row RECORD;
begin
	FOR row IN SELECT 'DROP ' || routines.routine_type || ' ' || schema_name || '.' || routines.routine_name || '(' || COALESCE(STRING_AGG(parameters.parameter_mode || ' ' || parameters.udt_name,',' ORDER BY parameters.ordinal_position), '') || ');' AS drop_command
	FROM information_schema.routines
	    LEFT JOIN information_schema.parameters ON routines.specific_name=parameters.specific_name
	WHERE routines.specific_schema=schema_name
	GROUP by routines.routine_type, routines.specific_name, routines.routine_name
	LOOP
		EXECUTE row.drop_command;
	END LOOP;
END;
$$ LANGUAGE plpgsql;

CALL __DROP_FUNCTIONS('@@PG_PREFIX@@carto');
