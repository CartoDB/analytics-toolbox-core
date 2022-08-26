const { runQuery } = require('../../../common/test-utils');

test('ST_TILEENVELOPE should work', async () => {
    const query = `
        SELECT ST_TILEENVELOPE(10, 384, 368) as geog1,
               ST_TILEENVELOPE(18, 98304, 94299) as geog2,
               ST_TILEENVELOPE(25, 12582912, 12070369) as geog3
    `;
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(JSON.stringify(rows[0].GEOG1)).toEqual('{"coordinates":[[[-45,45.08903556483103],[-45,44.840290651397986],[-44.6484375,44.840290651397986],[-44.6484375,45.08903556483103],[-45,45.08903556483103]]],"type":"Polygon"}');
    expect(JSON.stringify(rows[0].GEOG2)).toEqual('{"coordinates":[[[-45,45.00073807829068],[-45,44.99976701918129],[-44.998626708984375,44.99976701918129],[-44.998626708984375,45.00073807829068],[-45,45.00073807829068]]],"type":"Polygon"}');
    expect(JSON.stringify(rows[0].GEOG3)).toEqual('{"coordinates":[[[-45,45.00000219906962],[-45,44.999994612636684],[-44.99998927116394,44.999994612636684],[-44.99998927116394,45.00000219906962],[-45,45.00000219906962]]],"type":"Polygon"}');
});

test('ST_TILEENVELOPE should fail if any NULL argument', async () => {
    const query = `
        SELECT ST_TILEENVELOPE(10, 384, null)
    `;
    await expect(runQuery(query)).rejects.toThrow();
});