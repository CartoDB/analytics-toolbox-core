--------------------------------
-- Copyright (C) 2026 CARTO
--------------------------------

CREATE OR REPLACE PROCEDURE @@RS_SCHEMA@@.CREATE_CLUSTERDBSCAN
(
    input VARCHAR(MAX),
    output_table INOUT VARCHAR(MAX),
    geom_column VARCHAR(MAX),
    epsilon FLOAT8,
    min_points INT,
    partition_column VARCHAR(MAX)
)
AS $$
DECLARE
    input_query   VARCHAR(MAX);
    table_format  INTEGER;
    output_first  VARCHAR(MAX);
    output_second VARCHAR(MAX);
    output_third  VARCHAR(MAX);
    output_fourth VARCHAR(MAX);
    bad_geom      BIGINT;
    part_expr     VARCHAR(MAX);
    dist_col      VARCHAR(MAX);
    lat_max       FLOAT8;
    sin_half      FLOAT8;
    cos_lat       FLOAT8;
    dlat          FLOAT8;
    dlon          FLOAT8;
    gx_span       BIGINT;
    n_changed     BIGINT := 1;
    n_iter        INTEGER := 0;
    max_iter      INTEGER := 100;
    cc_cur        VARCHAR(MAX) := '__carto_dbscan_cc_a';
    cc_nxt        VARCHAR(MAX) := '__carto_dbscan_cc_b';
    cc_swap       VARCHAR(MAX);
BEGIN
    ------------------------------------------------------------------
    -- 0. Validate arguments
    ------------------------------------------------------------------
    IF epsilon IS NULL OR epsilon <= 0
    THEN
        output_table := 'Invalid epsilon. It must be a positive distance in meters';
        RAISE INFO 'Invalid epsilon. It must be a positive distance in meters';
        RETURN;
    END IF;

    IF min_points IS NULL OR min_points < 1
    THEN
        output_table := 'Invalid min_points. It must be >= 1';
        RAISE INFO 'Invalid min_points. It must be >= 1';
        RETURN;
    END IF;

    -- Accept either a table name or a subquery, as CREATE_CLUSTERKMEANS does
    input_query := input;
    EXECUTE 'SELECT regexp_count(''' || input || ''', ''\\\\s'')' INTO table_format;
    IF table_format > 0
    THEN
        input_query := '(' || input || ')';
    END IF;

    -- Validate output table
    EXECUTE 'SELECT split_part(''' || output_table || ''', ''.'', 1)' INTO output_first;
    EXECUTE 'SELECT split_part(''' || output_table || ''', ''.'', 2)' INTO output_second;
    EXECUTE 'SELECT split_part(''' || output_table || ''', ''.'', 3)' INTO output_third;
    EXECUTE 'SELECT split_part(''' || output_table || ''', ''.'', 4)' INTO output_fourth;
    IF output_first = '' OR output_second = '' OR output_fourth != ''
    THEN
        output_table := 'Invalid output table name. It must have the form [DATABASE.]SCHEMA.TABLE';
        RAISE INFO 'Invalid output table name. It must have the form [DATABASE.]SCHEMA.TABLE';
        RETURN;
    END IF;

    -- ST_DistanceSphere reads coordinates as degrees and only accepts points.
    -- SRID 0 is tolerated (lon/lat without a declared SRID is common); anything
    -- else non-4326 is almost certainly projected and would be silently wrong.
    EXECUTE 'SELECT COUNT(*) FROM ' || input_query || '
             WHERE ' || geom_column || ' IS NOT NULL
               AND (ST_GeometryType(' || geom_column || ') <> ''ST_Point''
                    OR ST_SRID(' || geom_column || ') NOT IN (0, 4326))' INTO bad_geom;
    IF bad_geom > 0
    THEN
        output_table := 'Invalid geometry column. Expected POINT in SRID 4326 (or 0)';
        RAISE INFO 'Invalid geometry column. Expected POINT in SRID 4326 (or 0)';
        RETURN;
    END IF;

    IF partition_column IS NULL OR BTRIM(partition_column) = ''
    THEN
        -- Single global partition. Distribute by latitude band so one slice does
        -- not receive the whole dataset.
        part_expr := '''0''';
        dist_col  := 'gy';
    ELSE
        -- The partition key is compared with an equality join, which never
        -- matches NULL to NULL. Cast it to VARCHAR and substitute a sentinel so
        -- that rows with a NULL partition value form their own group, which is
        -- what SQL PARTITION BY / GROUP BY do and what BigQuery's
        -- ST_CLUSTERDBSCAN(...) OVER (PARTITION BY ...) would do. Excluding them
        -- instead would silently drop rows from the analysis.
        part_expr := 'COALESCE(' || partition_column ||
                     '::VARCHAR, ''__carto_null_partition__'')';
        dist_col  := 'part';
    END IF;

    ------------------------------------------------------------------
    -- 1. Output table: every input column, plus index and labels
    ------------------------------------------------------------------
    -- __carto_idx is ordered by coordinate, not by physical row order, so the
    -- cluster ids below are reproducible across runs.
    -- pt_type defaults to 'skipped'; step 9 overwrites it for every row that was
    -- actually clustered, so rows with a NULL geometry keep it without needing a
    -- second pass over the table. A NULL geometry is the ONLY reason a row is
    -- skipped: it is absent input, not a density result, so reporting it as
    -- 'noise' would claim the location is isolated when it has no location.
    EXECUTE 'DROP TABLE IF EXISTS ' || output_table;
    EXECUTE 'CREATE TABLE ' || output_table || ' AS
        SELECT *,
               ROW_NUMBER() OVER (
                   ORDER BY ST_X(' || geom_column || '), ST_Y(' || geom_column || ')
               ) AS __carto_idx,
               NULL::BIGINT     AS cluster_id,
               ''skipped''::VARCHAR(8) AS pt_type
        FROM ' || input_query;

    ------------------------------------------------------------------
    -- 2. Grid parameters for the neighbour pre-filter
    ------------------------------------------------------------------
    -- dlat/dlon are sized so that any two points within epsilon fall in the same
    -- or an adjacent cell. dlon is computed at the HIGHEST |latitude| present,
    -- where a degree of longitude is shortest, so it is an upper bound
    -- everywhere in the data. See "Why the grid pre-filter is exact".
    EXECUTE 'SELECT COALESCE(MAX(ABS(ST_Y(' || geom_column || '))), 0)
             FROM ' || output_table INTO lat_max;

    -- Bounds derived directly from the haversine identity, so the 3x3 ring is
    -- provably sufficient for ANY epsilon and ANY latitude:
    --   |d_lat|   <= epsilon/R                                    (meridian arc, exact)
    --   |d_lon|/2 <= ASIN( SIN(epsilon/2R) / COS(lat_max) )       (haversine, exact)
    -- Do NOT substitute a linear meters-per-degree approximation for the second
    -- bound: it understates d_lon by roughly (epsilon/2R)^2/6 * TAN(lat)^2, which
    -- exceeds the 1% margin below once epsilon*TAN(lat) passes ~3000 km, and silently
    -- drops pairs. The 1% margin absorbs the exact sphere radius Redshift uses
    -- internally and the float round-trip of these literals into the dynamic SQL.
    -- Oversized cells only add candidate pairs; they can never drop a true pair.
    dlat     := 1.01 * DEGREES(epsilon / 6371008.8);
    sin_half := SIN(epsilon / (2.0 * 6371008.8));
    cos_lat  := COS(RADIANS(LEAST(lat_max, 89.999999)));

    IF sin_half >= cos_lat
    THEN
        -- epsilon spans the pole at this latitude: no longitude filtering is valid
        dlon := 360.0;
    ELSE
        dlon := 1.01 * DEGREES(2.0 * ASIN(sin_half / cos_lat));
    END IF;

    -- LOAD-BEARING: gx_span < 3 would make the +/-1 ring repeat cells, emitting
    -- DUPLICATE edge rows, which inflates the degree count in step 6 and
    -- misclassifies core points. Capping dlon keeps gx_span >= 3; with only 3
    -- cells every cell is adjacent to every other, so completeness is trivial.
    IF dlon > 120.0
    THEN
        dlon := 120.0;
    END IF;
    gx_span := CEIL(360.0 / dlon)::BIGINT;

    ------------------------------------------------------------------
    -- 3. Normalized point set
    ------------------------------------------------------------------
    -- gx is reduced modulo gx_span so the antimeridian wraps correctly:
    -- lon 179.99 and lon -179.99 land in the same cell.
    EXECUTE 'DROP TABLE IF EXISTS __carto_dbscan_pts';
    EXECUTE 'CREATE TEMP TABLE __carto_dbscan_pts
             DISTKEY(' || dist_col || ') SORTKEY(part, gy, gx) AS
        SELECT __carto_idx AS idx,
               ' || part_expr || ' AS part,
               ' || geom_column || ' AS geom,
               ((FLOOR(ST_X(' || geom_column || ') / ' || dlon || ')::BIGINT
                 % ' || gx_span || ') + ' || gx_span || ') % ' || gx_span || ' AS gx,
               FLOOR(ST_Y(' || geom_column || ') / ' || dlat || ')::BIGINT AS gy
        FROM ' || output_table || '
        WHERE ' || geom_column || ' IS NOT NULL';

    ------------------------------------------------------------------
    -- 4. Probe cells: each point claims its own cell and its 8 neighbours
    ------------------------------------------------------------------
    -- Expanding the 3x3 ring on one side turns the range predicate into an
    -- equijoin, so step 5 is a hash join rather than a nested loop.
    EXECUTE 'DROP TABLE IF EXISTS __carto_dbscan_probe';
    EXECUTE 'CREATE TEMP TABLE __carto_dbscan_probe
             DISTKEY(' || dist_col || ') SORTKEY(part, gy, gx) AS
        SELECT p.idx,
               p.part,
               p.geom,
               ((p.gx + o.dx) % ' || gx_span || ' + ' || gx_span || ')
                   % ' || gx_span || ' AS gx,
               p.gy + o.dy AS gy
        FROM __carto_dbscan_pts p
        CROSS JOIN (
            SELECT -1 AS dx, -1 AS dy
            UNION ALL SELECT -1, 0 UNION ALL SELECT -1, 1
            UNION ALL SELECT  0, -1 UNION ALL SELECT  0, 0
            UNION ALL SELECT  0, 1  UNION ALL SELECT  1, -1
            UNION ALL SELECT  1, 0  UNION ALL SELECT  1, 1
        ) o';

    ------------------------------------------------------------------
    -- 5. Neighbour edges (exact distance test, symmetric)
    ------------------------------------------------------------------
    -- The connected-components proof in step 7 REQUIRES a symmetric edge set.
    -- Rather than relying on ST_DistanceSphere(a,b) = ST_DistanceSphere(b,a)
    -- holding bit-for-bit at the epsilon boundary, build the a < b direction only
    -- and mirror it. This makes symmetry structural, and halves the number of
    -- distance evaluations.
    EXECUTE 'DROP TABLE IF EXISTS __carto_dbscan_edges';
    EXECUTE 'CREATE TEMP TABLE __carto_dbscan_edges DISTKEY(b) SORTKEY(a) AS
        WITH half AS (
            SELECT pr.idx AS a, p.idx AS b
            FROM __carto_dbscan_probe pr
            JOIN __carto_dbscan_pts p
              ON p.part = pr.part
             AND p.gx   = pr.gx
             AND p.gy   = pr.gy
            WHERE pr.idx < p.idx
              AND ST_DistanceSphere(pr.geom, p.geom) <= ' || epsilon || '
        )
        SELECT a, b FROM half
        UNION ALL
        SELECT b AS a, a AS b FROM half';

    ------------------------------------------------------------------
    -- 6. Core points (degree including self >= min_points)
    ------------------------------------------------------------------
    EXECUTE 'DROP TABLE IF EXISTS __carto_dbscan_core';
    EXECUTE 'CREATE TEMP TABLE __carto_dbscan_core DISTKEY(idx) SORTKEY(idx) AS
        SELECT p.idx,
               CASE WHEN COALESCE(d.deg, 0) + 1 >= ' || min_points || '
                    THEN 1 ELSE 0 END AS is_core
        FROM __carto_dbscan_pts p
        LEFT JOIN (
            SELECT a AS idx, COUNT(*) AS deg
            FROM __carto_dbscan_edges GROUP BY a
        ) d ON d.idx = p.idx';

    ------------------------------------------------------------------
    -- 7. Connected components over core-to-core edges
    ------------------------------------------------------------------
    EXECUTE 'DROP TABLE IF EXISTS __carto_dbscan_ce';
    EXECUTE 'CREATE TEMP TABLE __carto_dbscan_ce DISTKEY(b) SORTKEY(a) AS
        SELECT e.a, e.b
        FROM __carto_dbscan_edges e
        JOIN __carto_dbscan_core ca ON ca.idx = e.a AND ca.is_core = 1
        JOIN __carto_dbscan_core cb ON cb.idx = e.b AND cb.is_core = 1';

    EXECUTE 'DROP TABLE IF EXISTS ' || cc_cur;
    EXECUTE 'DROP TABLE IF EXISTS ' || cc_nxt;
    EXECUTE 'CREATE TEMP TABLE ' || cc_cur || ' DISTKEY(idx) SORTKEY(idx) AS
        SELECT idx, idx AS comp
        FROM __carto_dbscan_core WHERE is_core = 1';

    -- Each pass does min-label propagation followed by one pointer jump
    -- (comp := comp[comp]). Both steps are monotonically non-increasing and
    -- preserve "comp[v] is a member of v's component", so the fixpoint is
    -- unchanged; the jump only halves the remaining path length per pass.
    WHILE n_changed > 0 AND n_iter < max_iter LOOP
        n_iter := n_iter + 1;

        EXECUTE 'DROP TABLE IF EXISTS ' || cc_nxt;
        EXECUTE 'CREATE TEMP TABLE ' || cc_nxt || ' DISTKEY(idx) SORTKEY(idx) AS
            WITH prop AS (
                SELECT c.idx,
                       LEAST(c.comp, COALESCE(MIN(cn.comp), c.comp)) AS comp
                FROM ' || cc_cur || ' c
                LEFT JOIN __carto_dbscan_ce e ON e.a = c.idx
                LEFT JOIN ' || cc_cur || ' cn ON cn.idx = e.b
                GROUP BY c.idx, c.comp
            )
            SELECT p.idx, COALESCE(j.comp, p.comp) AS comp
            FROM prop p
            LEFT JOIN prop j ON j.idx = p.comp';

        EXECUTE 'SELECT COUNT(*) FROM ' || cc_nxt || ' n
                 JOIN ' || cc_cur || ' o ON o.idx = n.idx
                 WHERE n.comp <> o.comp' INTO n_changed;

        cc_swap := cc_cur; cc_cur := cc_nxt; cc_nxt := cc_swap;
    END LOOP;

    IF n_changed > 0
    THEN
        output_table := 'Clustering did not converge in ' || max_iter || ' iterations';
        RAISE INFO 'Clustering did not converge in % iterations', max_iter;
        RETURN;
    END IF;

    ------------------------------------------------------------------
    -- 8. Border points: smallest component label among core neighbours
    ------------------------------------------------------------------
    -- MIN over canonical component labels reproduces sklearn exactly: sklearn
    -- opens clusters in increasing order of minimum core index and never
    -- relabels, so a border point joins the cluster with the smallest
    -- minimum-core-index among its core neighbours.
    EXECUTE 'DROP TABLE IF EXISTS __carto_dbscan_border';
    EXECUTE 'CREATE TEMP TABLE __carto_dbscan_border DISTKEY(idx) SORTKEY(idx) AS
        SELECT e.a AS idx, MIN(cc.comp) AS comp
        FROM __carto_dbscan_edges e
        JOIN __carto_dbscan_core na ON na.idx = e.a AND na.is_core = 0
        JOIN __carto_dbscan_core nb ON nb.idx = e.b AND nb.is_core = 1
        JOIN ' || cc_cur || ' cc     ON cc.idx = e.b
        GROUP BY e.a';

    ------------------------------------------------------------------
    -- 9. Write labels back
    ------------------------------------------------------------------
    -- cluster_id is 0-based and dense per partition, matching sklearn labels_
    -- and BigQuery ST_CLUSTERDBSCAN. Noise is NULL (BigQuery convention;
    -- sklearn uses -1).
    EXECUTE 'UPDATE ' || output_table || ' SET
                cluster_id = s.cluster_id,
                pt_type    = s.pt_type
             FROM (
                SELECT lab.idx,
                       CASE WHEN lab.raw_comp IS NULL THEN NULL
                            ELSE DENSE_RANK() OVER (
                                     PARTITION BY lab.part ORDER BY lab.raw_comp
                                 ) - 1
                       END AS cluster_id,
                       lab.pt_type
                FROM (
                    SELECT p.idx,
                           p.part,
                           CASE WHEN co.is_core = 1        THEN cc.comp
                                WHEN bo.comp IS NOT NULL   THEN bo.comp
                                ELSE NULL END AS raw_comp,
                           CASE WHEN co.is_core = 1        THEN ''core''
                                WHEN bo.comp IS NOT NULL   THEN ''border''
                                ELSE ''noise'' END AS pt_type
                    FROM __carto_dbscan_pts p
                    JOIN __carto_dbscan_core co ON co.idx = p.idx
                    LEFT JOIN ' || cc_cur || ' cc ON cc.idx = p.idx
                    LEFT JOIN __carto_dbscan_border bo ON bo.idx = p.idx
                ) lab
             ) s
             WHERE __carto_idx = s.idx';

    ------------------------------------------------------------------
    -- 10. Clean up
    ------------------------------------------------------------------
    EXECUTE 'ALTER TABLE ' || output_table || ' DROP COLUMN __carto_idx';
    EXECUTE 'DROP TABLE IF EXISTS __carto_dbscan_pts';
    EXECUTE 'DROP TABLE IF EXISTS __carto_dbscan_probe';
    EXECUTE 'DROP TABLE IF EXISTS __carto_dbscan_edges';
    EXECUTE 'DROP TABLE IF EXISTS __carto_dbscan_core';
    EXECUTE 'DROP TABLE IF EXISTS __carto_dbscan_ce';
    EXECUTE 'DROP TABLE IF EXISTS __carto_dbscan_border';
    EXECUTE 'DROP TABLE IF EXISTS __carto_dbscan_cc_a';
    EXECUTE 'DROP TABLE IF EXISTS __carto_dbscan_cc_b';

    output_table := 'Table ' || output_table || ' created with the clustering';
END;
$$ LANGUAGE plpgsql;


-- Convenience overload: no partition column (cluster the whole input as one set)
CREATE OR REPLACE PROCEDURE @@RS_SCHEMA@@.CREATE_CLUSTERDBSCAN
(
    input VARCHAR(MAX),
    output_table INOUT VARCHAR(MAX),
    geom_column VARCHAR(MAX),
    epsilon FLOAT8,
    min_points INT
)
AS $$
BEGIN
    CALL @@RS_SCHEMA@@.CREATE_CLUSTERDBSCAN(
        input, output_table, geom_column, epsilon, min_points, NULL
    );
END;
$$ LANGUAGE plpgsql;
