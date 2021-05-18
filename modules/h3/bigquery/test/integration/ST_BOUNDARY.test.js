const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('Returns NULL with invalid parameters', async () => {
    const query = `
        WITH ids AS
        (
            SELECT 1 AS id, NULL as hid UNION ALL
            SELECT 2 AS id, 'ff283473fffffff' as hid
        )
        SELECT
            id,
            \`@@BQ_PREFIX@@h3.ST_BOUNDARY\`(hid) as bounds
        FROM ids
        ORDER BY id ASC
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(2);
    expect(rows[0].bounds).toEqual(null);
    expect(rows[1].bounds).toEqual(null);
});

test('Returns NULL the expected geography', async () => {
    const query = `
        WITH ids AS
        (
            SELECT 1 AS id, '85283473fffffff' as hid, ST_GEOGFROMTEXT('POLYGON((-121.91508032705622 37.271355866731895, -121.86222328902491 37.353926450852256, -121.9235499963016 37.42834118609435, -122.0377349642703 37.42012867767778, -122.09042892904395 37.33755608435298, -122.02910130919 37.26319797461824, -121.91508032705622 37.2713558667318959))') AS expected UNION ALL
            SELECT 2 AS id, '81623ffffffffff' as hid, ST_GEOGFROMTEXT('POLYGON((55.94007484027041 12.754829243237465, 55.178175815407634 10.2969712998247, 55.25056228923789 9.092686031788569, 57.37516125699395 7.616228186063625, 58.549882762724735 7.302087248609307, 60.638711932789995 8.825639091130396, 61.315435771664646 9.83036925628956, 60.502253257733344 12.271971757766304, 59.732575088573185 13.216340916028171, 57.09422515125156 13.191260467897605, 55.94007484027041 12.754829243237465))') AS expected
        )
        SELECT
            *,
            \`@@BQ_PREFIX@@h3.ST_BOUNDARY\`(hid) as bounds
        FROM ids
        WHERE NOT ST_EQUALS(expected, \`@@BQ_PREFIX@@h3.ST_BOUNDARY\`(hid))
    `;

    const rows = await runQuery(query);
    expect(rows.length).toEqual(0);
});