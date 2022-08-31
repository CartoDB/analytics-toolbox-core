const { runQuery } = require('../../../common/test-utils');

test('QUADINT_BOUNDARY should work', async () => {
    const query = `
        SELECT
            QUADINT_BOUNDARY(0) as geog1,
            QUADINT_BOUNDARY(1) as geog2,
            QUADINT_BOUNDARY(2) as geog3,
            QUADINT_BOUNDARY(12070922) as geog4,
            QUADINT_BOUNDARY(791040491538) as geog5,
            QUADINT_BOUNDARY(12960460429066265) as geog6`;
    
    const rows = await runQuery(query);
    expect(rows.length).toEqual(1);
    expect(JSON.stringify(rows[0]['GEOG1'])).toEqual('{"coordinates":[[[-180,85.0511287798066],[-180,-85.0511287798066],[180,-85.0511287798066],[180,85.0511287798066],[-180,85.0511287798066]]],"type":"Polygon"}');
    expect(JSON.stringify(rows[0]['GEOG2'])).toEqual('{"coordinates":[[[-180,85.0511287798066],[-180,0],[0,0],[0,85.0511287798066],[-180,85.0511287798066]]],"type":"Polygon"}');
    expect(JSON.stringify(rows[0]['GEOG3'])).toEqual('{"coordinates":[[[-180,85.0511287798066],[-180,66.51326044311186],[-90,66.51326044311186],[-90,85.0511287798066],[-180,85.0511287798066]]],"type":"Polygon"}');
    expect(JSON.stringify(rows[0]['GEOG4'])).toEqual('{"coordinates":[[[-45,45.08903556483103],[-45,44.840290651397986],[-44.6484375,44.840290651397986],[-44.6484375,45.08903556483103],[-45,45.08903556483103]]],"type":"Polygon"}');
    expect(JSON.stringify(rows[0]['GEOG5'])).toEqual('{"coordinates":[[[-45,45.00073807829068],[-45,44.99976701918129],[-44.998626708984375,44.99976701918129],[-44.998626708984375,45.00073807829068],[-45,45.00073807829068]]],"type":"Polygon"}');
    expect(JSON.stringify(rows[0]['GEOG6'])).toEqual('{"coordinates":[[[-45,45.00000219906962],[-45,44.999994612636684],[-44.99998927116394,44.999994612636684],[-44.99998927116394,45.00000219906962],[-45,45.00000219906962]]],"type":"Polygon"}');
});

test('QUADINT_BOUNDARY should fail with NULL argument', async () => {
    const query = 'SELECT QUADINT_BOUNDARY(NULL);';
    await expect(runQuery(query)).rejects.toThrow();
});