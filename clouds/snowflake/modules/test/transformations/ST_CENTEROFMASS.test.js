const { runQuery } = require('../../../common/test-utils');

test('ST_CENTEROFMASS should work', async () => {
    const query = `SELECT ST_CENTEROFMASS(TO_GEOGRAPHY('POLYGON ((4.77802276611328 45.7784187892391, 4.77338790893555 45.7402141789073, 4.82419967651367 45.713371483331, 4.89492416381836 45.7271539426975, 4.91037368774414 45.7608167797245, 4.88239288330078 45.792544274359, 4.82505798339844 45.7939805638674, 4.77802276611328 45.7784187892391))')) as centerOfMass1,
    ST_CENTEROFMASS(TO_GEOGRAPHY('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))')) as centerOfMass2,
    ST_CENTEROFMASS(TO_GEOGRAPHY('POLYGON ((-120 30, -90 40, 20 40, -45 -20, -120 30))')) as centerOfMass3`;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(JSON.stringify(rows[0].CENTEROFMASS1)).toEqual('{"coordinates":[4.840728965137101,45.75581209996417],"type":"Point"}');
    expect(JSON.stringify(rows[0].CENTEROFMASS2)).toEqual('{"coordinates":[25.454545454545453,26.96969696969697],"type":"Point"}');
    expect(JSON.stringify(rows[0].CENTEROFMASS3)).toEqual('{"coordinates":[-50.19774011299435,19.152542372881356],"type":"Point"}');
});

test('ST_CENTEROFMASS should return NULL if any NULL mandatory argument', async () => {
    const query = 'SELECT ST_CENTEROFMASS(NULL) as centerofmass1';
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(rows[0].CENTEROFMASS1).toEqual(null);
});