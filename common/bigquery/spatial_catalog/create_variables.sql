CREATE OR REPLACE TABLE `@@BQ_PROJECT@@.carto.spatial_catalog_variables` AS
    SELECT * FROM EXTERNAL_QUERY(
      "@@BQ_CONNECTION_SPATIAL_CATALOG@@",
      R"""
      SELECT
        v.slug AS variable_slug,
        v.column_name AS variable_name,
        v.description AS variable_description,
        v.db_type::text AS variable_type,
        v.agg_method::text AS variable_aggregation,
        d.slug  AS dataset_slug
      FROM variables v
      JOIN datasets d ON (d.id = v.dataset_id)

      UNION ALL

      SELECT
        v.slug AS variable_slug,
        v.column_name AS variable_name,
        v.description AS variable_description,
        v.db_type::text AS variable_type,
        v.agg_method::text AS variable_aggregation,
        g.slug  AS dataset_slug
      FROM geographies_variables v
      JOIN geographies g ON (g.id = v.geography_id)
      """
    );
