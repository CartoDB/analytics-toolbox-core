const { runQuery } = require('../../../common/test-utils');

test('ST_CENTERMEAN should work', async () => {
    const query = `SELECT \`@@BQ_DATASET@@.ST_CENTERMEAN\`(ST_GEOGFROMTEXT("POLYGON ((4.77802276611328 45.7784187892391, 4.77338790893555 45.7402141789073, 4.82419967651367 45.713371483331, 4.89492416381836 45.7271539426975, 4.91037368774414 45.7608167797245, 4.88239288330078 45.792544274359, 4.82505798339844 45.7939805638674, 4.77802276611328 45.7784187892391))")) as centerMean1,
    \`@@BQ_DATASET@@.ST_CENTERMEAN\`(ST_GEOGFROMTEXT("POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))")) as centerMean2,
    \`@@BQ_DATASET@@.ST_CENTERMEAN\`(ST_GEOGFROMTEXT("POLYGON ((-120 30, -90 40, 20 40, -45 -20, -120 30))")) as centerMean3`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].centerMean1.value).toEqual('POINT(4.83329772949219 45.7606148501706)');
    expect(rows[0].centerMean2.value).toEqual('POINT(25.3890912155939 29.7916831655627)');
    expect(rows[0].centerMean3.value).toEqual('POINT(-47.9686961224971 29.5918778893822)');
});

test('ST_CENTERMEAN should return NULL if any NULL mandatory argument', async () => {
    const query = 'SELECT `@@BQ_DATASET@@.ST_CENTERMEAN`(NULL) as centermean1';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].centermean1).toEqual(null);
});