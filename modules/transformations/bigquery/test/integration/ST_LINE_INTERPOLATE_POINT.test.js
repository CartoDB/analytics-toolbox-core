const { runQuery } = require('../../../../../common/bigquery/test-utils');

test('ST_LINE_INTERPOLATE_POINT should work', async () => {
    const query = `SELECT \`@@BQ_PREFIX@@transformations.ST_LINE_INTERPOLATE_POINT\`(ST_GEOGFROMTEXT("LINESTRING (0 0, 10 0)"), 250,'kilometers') as interpolation1,
    \`@@BQ_PREFIX@@transformations.ST_LINE_INTERPOLATE_POINT\`(ST_GEOGFROMTEXT("LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)"), 10, 'kilometers') as interpolation2,
    \`@@BQ_PREFIX@@transformations.ST_LINE_INTERPOLATE_POINT\`(ST_GEOGFROMTEXT("LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)"), 10, 'miles') as interpolation3`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].interpolation1.value).toEqual('POINT(2.24830090931135 1.41962393090655e-15)');
    expect(rows[0].interpolation2.value).toEqual('POINT(-76.1751049248225 18.4695609401574)');
    expect(rows[0].interpolation3.value).toEqual('POINT(-76.2261862171845 18.4951718538225)');
});

test('ST_LINE_INTERPOLATE_POINT should return NULL if any NULL mandatory argument', async () => {
    const query = `SELECT \`@@BQ_PREFIX@@transformations.ST_LINE_INTERPOLATE_POINT\`(NULL, 250,'miles') as interpolation1,
    \`@@BQ_PREFIX@@transformations.ST_LINE_INTERPOLATE_POINT\`(ST_GEOGFROMTEXT("LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)"), NULL, 'miles') as interpolation2`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].interpolation1).toEqual(null);
    expect(rows[0].interpolation2).toEqual(null);
});

test('ST_LINE_INTERPOLATE_POINT default values should work', async () => {
    const query = `SELECT \`@@BQ_PREFIX@@transformations.ST_LINE_INTERPOLATE_POINT\`(ST_GEOGFROMTEXT("LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)"), 250, 'kilometers') as defaultValue,
    \`@@BQ_PREFIX@@transformations.ST_LINE_INTERPOLATE_POINT\`(ST_GEOGFROMTEXT("LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)"), 250, NULL) as nullParam1`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].nullParam1).toEqual(rows[0].defaultValue);
});
