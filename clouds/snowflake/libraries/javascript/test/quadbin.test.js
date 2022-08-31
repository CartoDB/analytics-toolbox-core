const quadbinLib = require('../build/quadbin');

test('quadbin library defined', () => {
    expect(quadbinLib.getQuadbinPolygon).toBeDefined();
    expect(quadbinLib.getQuadbinBoundingBox).toBeDefined();
    expect(quadbinLib.quadbinToTile).toBeDefined();
    expect(quadbinLib.tileToQuadbin).toBeDefined();
    expect(quadbinLib.geojsonToQuadbins).toBeDefined();
});