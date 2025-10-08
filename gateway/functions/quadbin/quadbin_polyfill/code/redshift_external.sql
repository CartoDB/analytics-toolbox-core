{# Jinja2 template for Redshift external function SQL #}
{# Variables available: function_name, lambda_arn, iam_role_arn, schema #}

-- Internal external function (VARCHAR in/out)
CREATE OR REPLACE EXTERNAL FUNCTION {{ schema }}.__QUADBIN_POLYFILL_EXFUNC(
    geom VARCHAR(MAX),
    resolution INTEGER
)
RETURNS VARCHAR(MAX)
STABLE
LAMBDA '{{ lambda_arn }}'
IAM_ROLE '{{ iam_role_arn }}';

-- Public wrapper function (GEOMETRY in, SUPER out)
CREATE OR REPLACE FUNCTION {{ schema }}.QUADBIN_POLYFILL(
    geom GEOMETRY,
    resolution INTEGER
)
RETURNS SUPER
STABLE
AS $$
    SELECT CASE ST_SRID($1)
        WHEN 0 THEN JSON_PARSE({{ schema }}.__QUADBIN_POLYFILL_EXFUNC(ST_ASGEOJSON(ST_SETSRID($1, 4326))::VARCHAR(MAX), $2))
        ELSE JSON_PARSE({{ schema }}.__QUADBIN_POLYFILL_EXFUNC(ST_ASGEOJSON(ST_TRANSFORM($1, 4326))::VARCHAR(MAX), $2))
    END
$$ LANGUAGE sql;
