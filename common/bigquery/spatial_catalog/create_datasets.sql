CREATE OR REPLACE TABLE `@@BQ_PROJECT@@.carto.spatial_catalog_datasets` AS
    SELECT * FROM EXTERNAL_QUERY(
      "@@BQ_CONNECTION_SPATIAL_CATALOG@@",
      R"""
      SELECT
        d.id AS dataset_id,
        d.slug  AS dataset_slug,
        d.name AS dataset_name,
        co.name AS dataset_country,
        c.name AS dataset_category,
        p.name AS dataset_provider,
        d.version AS dataset_version,
        s.geom_type::text AS dataset_geom_type,
        d.is_public_data AS dataset_is_public,
        d.is_product AS dataset_is_product,
        g.id AS associated_geography_id
      FROM datasets d
      LEFT OUTER JOIN geographies g ON (g.id = d.geography_id)
      LEFT OUTER JOIN categories c ON (c.id = d.category_id)
      LEFT OUTER JOIN providers p ON (p.id = d.provider_id)
      LEFT OUTER JOIN countries co ON (co.id = d.country_id)
      LEFT JOIN spatial_aggregations s ON (g.spatial_aggregation = s.id)

      UNION ALL

      SELECT
        g.id AS dataset_id,
        g.slug  AS dataset_slug,
        g.name AS dataset_name,
        co.name AS dataset_country,
        'Geography' AS dataset_category,
        p.name AS dataset_provider,
        g.version AS dataset_version,
        s.geom_type::text AS dataset_geom_type,
        g.is_public_data AS dataset_is_public,
        g.is_product AS dataset_is_product,
        NULL AS associated_geography_id -- used to be geography_id
      FROM geographies g
      LEFT OUTER JOIN providers p ON (p.id = g.provider_id)
      LEFT OUTER JOIN countries co ON (co.id = g.country_id)
      LEFT OUTER JOIN spatial_aggregations s ON (g.spatial_aggregation = s.id)
      """
    );
