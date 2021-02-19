const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
global.eval(fs.readFileSync('../../proj_library.js') + '');

describe('PROJ unit tests', () => {
    it('Version', async() => {
        assert.equal(projVersion(), 1);
    });
});

// Start the main app logic.

function startTests(chai, proj4, testPoints) {
    const assert = chai.assert;
    proj4.defs([
        ['EPSG:102018', '+proj=gnom +lat_0=90 +lon_0=0 +x_0=6300000 +y_0=6300000 +ellps=WGS84 +datum=WGS84 +units=m +no_defs'],
        ['testmerc', '+proj=merc +lon_0=5.937 +lat_ts=45.027 +ellps=sphere'],
        ['testmerc2', '+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +units=m +k=1.0 +nadgrids=@null +no_defs']
    ]);
    proj4.defs('esriOnline', 'PROJCS["WGS_1984_Web_Mercator_Auxiliary_Sphere",GEOGCS["GCS_WGS_1984",DATUM["D_WGS_1984",SPHEROID["WGS_1984",6378137.0,298.257223563]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]],PROJECTION["Mercator_Auxiliary_Sphere"],PARAMETER["False_Easting",0.0],PARAMETER["False_Northing",0.0],PARAMETER["Central_Meridian",0.0],PARAMETER["Standard_Parallel_1",0.0],PARAMETER["Auxiliary_Sphere_Type",0.0],UNIT["Meter",1.0]]');

    describe('parse', function() {
        it('should parse units', function() {
            assert.equal(proj4.defs('testmerc2').units, 'm');
        });
    });

    describe('proj2proj', function() {
        it('should work transforming from one projection to another', function() {
            const sweref99tm = '+proj=utm +zone=33 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs';
            const rt90 = '+lon_0=15.808277777799999 +lat_0=0.0 +k=1.0 +x_0=1500000.0 +y_0=0.0 +proj=tmerc +ellps=bessel +units=m +towgs84=414.1,41.3,603.1,-0.855,2.141,-7.023,0 +no_defs';
            const rslt = proj4(sweref99tm, rt90).forward([319180, 6399862]);
            assert.closeTo(rslt[0], 1271137.927561178, 0.000001);
            assert.closeTo(rslt[1], 6404230.291456626, 0.000001);
        });
        it('should work with a proj object', function() {
            const sweref99tm = proj4('+proj=utm +zone=33 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs');
            const rt90 = proj4('+lon_0=15.808277777799999 +lat_0=0.0 +k=1.0 +x_0=1500000.0 +y_0=0.0 +proj=tmerc +ellps=bessel +units=m +towgs84=414.1,41.3,603.1,-0.855,2.141,-7.023,0 +no_defs');
            const rslt = proj4(sweref99tm, rt90).forward([319180, 6399862]);
            assert.closeTo(rslt[0], 1271137.927561178, 0.000001);
            assert.closeTo(rslt[1], 6404230.291456626, 0.000001);
        });
    });

    describe('proj4', function() {
        describe('core', function() {
            testPoints.forEach(function(testPoint) {
                describe(testPoint.code, function() {
                    let xyAcc = 2;
                    let llAcc = 6;
                    if ('acc' in testPoint) {
                        if ('xy' in testPoint.acc) {
                            xyAcc = testPoint.acc.xy;
                        }
                        if ('ll' in testPoint.acc) {
                            llAcc = testPoint.acc.ll;
                        }
                    }
                    const xyEPSLN = Math.pow(10, -1 * xyAcc);
                    const llEPSLN = Math.pow(10, -1 * llAcc);
                    describe('traditional', function() {
                        it('should work with forwards', function() {
                            const proj = new proj4.Proj(testPoint.code);
                            const xy = proj4.transform(proj4.WGS84, proj, proj4.toPoint(testPoint.ll));
                            assert.closeTo(xy.x, testPoint.xy[0], xyEPSLN, 'x is close');
                            assert.closeTo(xy.y, testPoint.xy[1], xyEPSLN, 'y is close');
                        });
                        it('should work with backwards', function() {
                            const proj = new proj4.Proj(testPoint.code);
                            const ll = proj4.transform(proj, proj4.WGS84, proj4.toPoint(testPoint.xy));
                            assert.closeTo(ll.x, testPoint.ll[0], llEPSLN, 'lng is close');
                            assert.closeTo(ll.y, testPoint.ll[1], llEPSLN, 'lat is close');
                        });
                    });
                    describe('new method 2 param', function() {
                        it('shortcut method should work with an array', function() {
                            const xy = proj4(testPoint.code, testPoint.ll);
                            assert.closeTo(xy[0], testPoint.xy[0], xyEPSLN, 'x is close');
                            assert.closeTo(xy[1], testPoint.xy[1], xyEPSLN, 'y is close');
                        });
                        it('shortcut method should work with an object', function() {
                            const pt = {
                                x: testPoint.ll[0],
                                y: testPoint.ll[1]
                            };
                            const xy = proj4(testPoint.code, pt);
                            assert.closeTo(xy.x, testPoint.xy[0], xyEPSLN, 'x is close');
                            assert.closeTo(xy.y, testPoint.xy[1], xyEPSLN, 'y is close');
                        });
                        it('shortcut method should work with a point object', function() {
                            const pt = proj4.toPoint(testPoint.ll);
                            const xy = proj4(testPoint.code, pt);
                            assert.closeTo(xy.x, testPoint.xy[0], xyEPSLN, 'x is close');
                            assert.closeTo(xy.y, testPoint.xy[1], xyEPSLN, 'y is close');
                        });
                    });
                    describe('new method 3 param', function() {
                        it('shortcut method should work with an array', function() {
                            const xy = proj4(proj4.WGS84, testPoint.code, testPoint.ll);
                            assert.closeTo(xy[0], testPoint.xy[0], xyEPSLN, 'x is close');
                            assert.closeTo(xy[1], testPoint.xy[1], xyEPSLN, 'y is close');
                        });
                        it('shortcut method should work with an object', function() {
                            const pt = {
                                x: testPoint.ll[0],
                                y: testPoint.ll[1]
                            };
                            const xy = proj4(proj4.WGS84, testPoint.code, pt);
                            assert.closeTo(xy.x, testPoint.xy[0], xyEPSLN, 'x is close');
                            assert.closeTo(xy.y, testPoint.xy[1], xyEPSLN, 'y is close');
                        });
                        it('shortcut method should work with a point object', function() {
                            const pt = proj4.toPoint(testPoint.ll);
                            const xy = proj4(proj4.WGS84, testPoint.code, pt);
                            assert.closeTo(xy.x, testPoint.xy[0], xyEPSLN, 'x is close');
                            assert.closeTo(xy.y, testPoint.xy[1], xyEPSLN, 'y is close');
                        });
                    });
                    describe('new method 3 param other way', function() {
                        it('shortcut method should work with an array', function() {
                            const ll = proj4(testPoint.code, proj4.WGS84, testPoint.xy);
                            assert.closeTo(ll[0], testPoint.ll[0], llEPSLN, 'x is close');
                            assert.closeTo(ll[1], testPoint.ll[1], llEPSLN, 'y is close');
                        });
                        it('shortcut method should work with an object', function() {
                            const pt = {
                                x: testPoint.xy[0],
                                y: testPoint.xy[1]
                            };
                            // in case of geocentric proj we need Z value.
                            if (typeof testPoint.xy[2] === 'number') {
                                pt.z = testPoint.xy[2];
                            }
                            const ll = proj4(testPoint.code, proj4.WGS84, pt);
                            assert.closeTo(ll.x, testPoint.ll[0], llEPSLN, 'x is close');
                            assert.closeTo(ll.y, testPoint.ll[1], llEPSLN, 'y is close');
                        });
                        it('shortcut method should work with a point object', function() {
                            const pt = proj4.toPoint(testPoint.xy);
                            const ll = proj4(testPoint.code, proj4.WGS84, pt);
                            assert.closeTo(ll.x, testPoint.ll[0], llEPSLN, 'x is close');
                            assert.closeTo(ll.y, testPoint.ll[1], llEPSLN, 'y is close');
                        });
                    });
                    describe('1 param', function() {
                        it('forwards', function() {
                            const xy = proj4(testPoint.code).forward(testPoint.ll);
                            assert.closeTo(xy[0], testPoint.xy[0], xyEPSLN, 'x is close');
                            assert.closeTo(xy[1], testPoint.xy[1], xyEPSLN, 'y is close');
                        });
                        it('inverse', function() {
                            const ll = proj4(testPoint.code).inverse(testPoint.xy);
                            assert.closeTo(ll[0], testPoint.ll[0], llEPSLN, 'x is close');
                            assert.closeTo(ll[1], testPoint.ll[1], llEPSLN, 'y is close');
                        });
                    });
                    describe('proj object', function() {
                        it('should work with a 2 element array', function() {
                            const xy = proj4(new proj4.Proj(testPoint.code), testPoint.ll);
                            assert.closeTo(xy[0], testPoint.xy[0], xyEPSLN, 'x is close');
                            assert.closeTo(xy[1], testPoint.xy[1], xyEPSLN, 'y is close');
                        });
                        it('should work on element', function() {
                            const xy = proj4(new proj4.Proj(testPoint.code)).forward(testPoint.ll);
                            assert.closeTo(xy[0], testPoint.xy[0], xyEPSLN, 'x is close');
                            assert.closeTo(xy[1], testPoint.xy[1], xyEPSLN, 'y is close');
                        });
                        it('should work 3 element point object', function() {
                            const pt = proj4.toPoint(testPoint.xy);
                            const ll = proj4(new proj4.Proj(testPoint.code), proj4.WGS84, pt);
                            assert.closeTo(ll.x, testPoint.ll[0], llEPSLN, 'x is close');
                            assert.closeTo(ll.y, testPoint.ll[1], llEPSLN, 'y is close');
                        });
                    });
                });
            });
        });
        describe('points', function() {
            it('should ignore stuff it does not know', function() {
                const sweref99tm = '+proj=utm +zone=33 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs';
                const rt90 = '+lon_0=15.808277777799999 +lat_0=0.0 +k=1.0 +x_0=1500000.0 +y_0=0.0 +proj=tmerc +ellps=bessel +units=m +towgs84=414.1,41.3,603.1,-0.855,2.141,-7.023,0 +no_defs';
                const rslt = proj4(sweref99tm, rt90).forward({
                    x: 319180,
                    y: 6399862,
                    z: 0,
                    m: 1000,
                    method: function() {
                        return 'correct answer';
                    }
                });
                assert.closeTo(rslt.x, 1271137.927561178, 0.000001);
                assert.closeTo(rslt.y, 6404230.291456626, 0.000001);
                assert.equal(rslt.z, 0);
                assert.equal(rslt.m, 1000);
                assert.equal(rslt.method(), 'correct answer');
            });
            it('should be able to compute X Y Z M in geocenteric coordinates', function() {
                const epsg4978 = '+proj=geocent +datum=WGS84 +units=m +no_defs';
                const rslt = proj4(epsg4978).forward({
                    x: -7.76166,
                    y: 39.19685,
                    z: 0,
                    m: 1000,
                    method: function() {
                        return 'correct answer';
                    }
                });
                assert.closeTo(rslt.x, 4904199.584207411, 0.000001);
                assert.closeTo(rslt.y, -668448.8153664203, 0.000001);
                assert.closeTo(rslt.z, 4009276.930771821, 0.000001);
                assert.equal(rslt.m, 1000);
                assert.equal(rslt.method(), 'correct answer');
            });
        });
        describe('points array', function() {
            it('should ignore stuff it does not know', function() {
                const sweref99tm = '+proj=utm +zone=33 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs';
                const rt90 = '+lon_0=15.808277777799999 +lat_0=0.0 +k=1.0 +x_0=1500000.0 +y_0=0.0 +proj=tmerc +ellps=bessel +units=m +towgs84=414.1,41.3,603.1,-0.855,2.141,-7.023,0 +no_defs';
                const rslt = proj4(sweref99tm, rt90).forward([
                    319180,
                    6399862,
                    0,
                    1000
                ]);
                assert.closeTo(rslt[0], 1271137.927561178, 0.000001);
                assert.closeTo(rslt[1], 6404230.291456626, 0.000001);
                assert.equal(rslt[2], 0);
                assert.equal(rslt[3], 1000);
            });
            it('should be able to compute X Y Z M in geocenteric coordinates', function() {
                const epsg4978 = '+proj=geocent +datum=WGS84 +units=m +no_defs';
                const rslt = proj4(epsg4978).forward([
                    -7.76166,
                    39.19685,
                    0,
                    1000
                ]);
                assert.closeTo(rslt[0], 4904199.584207411, 0.000001);
                assert.closeTo(rslt[1], -668448.8153664203, 0.000001);
                assert.closeTo(rslt[2], 4009276.930771821, 0.000001);
                assert.equal(rslt[3], 1000);
            });
        });

        it('should use correct axis order', function() {
            const enu = 'PROJCS["NAD83 / Massachusetts Mainland", GEOGCS["NAD83", DATUM["North American Datum 1983", SPHEROID["GRS 1980", 6378137.0, 298.257222101, AUTHORITY["EPSG","7019"]], TOWGS84[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], AUTHORITY["EPSG","6269"]], PRIMEM["Greenwich", 0.0, AUTHORITY["EPSG","8901"]], UNIT["degree", 0.017453292519943295], AXIS["Geodetic longitude", EAST], AXIS["Geodetic latitude", NORTH], AUTHORITY["EPSG","4269"]], PROJECTION["Lambert_Conformal_Conic_2SP", AUTHORITY["EPSG","9802"]], PARAMETER["central_meridian", -71.5], PARAMETER["latitude_of_origin", 41.0], PARAMETER["standard_parallel_1", 42.68333333333334], PARAMETER["false_easting", 200000.0], PARAMETER["false_northing", 750000.0], PARAMETER["scale_factor", 1.0], PARAMETER["standard_parallel_2", 41.71666666666667], UNIT["m", 1.0], AXIS["Easting", EAST], AXIS["Northing", NORTH], AUTHORITY["EPSG","26986"]]';
            const neu = 'PROJCS["NAD83 / Massachusetts Mainland NE", GEOGCS["NAD83", DATUM["North American Datum 1983", SPHEROID["GRS 1980", 6378137.0, 298.257222101, AUTHORITY["EPSG","7019"]], TOWGS84[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], AUTHORITY["EPSG","6269"]], PRIMEM["Greenwich", 0.0, AUTHORITY["EPSG","8901"]], UNIT["degree", 0.017453292519943295], AXIS["Geodetic latitude", NORTH], AXIS["Geodetic longitude", EAST], AUTHORITY["EPSG","4269"]], PROJECTION["Lambert_Conformal_Conic_2SP", AUTHORITY["EPSG","9802"]], PARAMETER["central_meridian", -71.5], PARAMETER["latitude_of_origin", 41.0], PARAMETER["standard_parallel_1", 42.68333333333334], PARAMETER["false_easting", 200000.0], PARAMETER["false_northing", 750000.0], PARAMETER["scale_factor", 1.0], PARAMETER["standard_parallel_2", 41.71666666666667], UNIT["m", 1.0], AXIS["Northing", NORTH], AXIS["Easting", EAST], AUTHORITY["EPSG","26986"]]';
            const rslt = proj4(enu, neu).forward({
                x: 10.2,
                y: 43.4
            });
            assert.closeTo(rslt.x, 43.4, 0.000001);
            assert.closeTo(rslt.y, 10.2, 0.000001);
        });

        it('axes should be invertable', function() {
            const enu = '+proj=longlat +axis=enu';
            const esu = '+proj=longlat +axis=esu';
            const wnu = '+proj=longlat +axis=wnu';
            let result = proj4(enu, esu).forward({ x: 40, y: 50 });
            assert.closeTo(result.x, 40, 0.000001);
            assert.closeTo(result.y, -50, 0.000001);
            result = proj4(enu, wnu).forward({ x: 40, y: 50 });
            assert.closeTo(result.x, -40, 0.000001);
            assert.closeTo(result.y, 50, 0.000001);
        });

        describe('defs', function() {
            assert.equal(proj4.defs('testmerc'), proj4.defs.testmerc);
            proj4.defs('foo', '+proj=merc +lon_0=5.937 +lat_ts=45.027 +ellps=sphere');
            assert.typeOf(proj4.defs.foo, 'object');
            proj4.defs('urn:x-ogc:def:crs:EPSG:4326', proj4.defs('EPSG:4326'));
            assert.strictEqual(proj4.defs['urn:x-ogc:def:crs:EPSG:4326'], proj4.defs['EPSG:4326']);

            describe('wkt', function() {
                it('should provide the correct conversion factor for WKT GEOGCS projections', function() {
                    proj4.defs('EPSG:4269', 'GEOGCS["NAD83",DATUM["North_American_Datum_1983",SPHEROID["GRS 1980",6378137,298.257222101,AUTHORITY["EPSG","7019"]],AUTHORITY["EPSG","6269"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.01745329251994328,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4269"]]');
                    assert.equal(proj4.defs['EPSG:4269'].to_meter, 6378137 * 0.01745329251994328);

                    proj4.defs('EPSG:4279', 'GEOGCS["OS(SN)80",DATUM["OS_SN_1980",SPHEROID["Airy 1830",6377563.396,299.3249646,AUTHORITY["EPSG","7001"]],AUTHORITY["EPSG","6279"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.01745329251994328,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4279"]]');
                    assert.equal(proj4.defs['EPSG:4279'].to_meter, 6377563.396 * 0.01745329251994328);
                });
                it('should parse wkt and proj4 of the same crs and result in the same params', function() {
                    const s1 = 'GEOGCS["PSD93",DATUM["PDO_Survey_Datum_1993",SPHEROID["Clarke 1880 (RGS)",6378249.145,293.465,AUTHORITY["EPSG","7012"]],TOWGS84[-180.624,-225.516,173.919,-0.81,-1.898,8.336,16.7101],AUTHORITY["EPSG","6134"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.0174532925199433,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4134"]]';
                    const s2 = '+proj=longlat +ellps=clrk80 +towgs84=-180.624,-225.516,173.919,-0.81,-1.898,8.336,16.7101 +no_defs';
                    const crs1 = proj4(s1);
                    const crs2 = proj4(s2);
                    assert.equal(crs1.oProj.a, crs2.oProj.a);
                    // proj4 has different ellipsoid parameters that EPSG: http://epsg.io/4134
                    // assert.equal(crs1.oProj.b, crs2.oProj.b);
                });
                it('should handled defined points correctly', function() {
                    const prj = '+proj=utm +zone=31';
                    const proj = proj4(prj);
                    const res = proj.forward([3, 0]);
                    assert.deepEqual(res, [500000, 0]);
                });
            });
        });
        describe('errors', function() {
            /* eslint-disable no-new */
            it('should throw an error for an unknown ref', function() {
                assert.throws(function() {
                    new proj4.Proj('fake one');
                }, 'fake one', 'should work');
            });
            /* eslint-enable no-new */
            it('should throw when passed null', function() {
                assert.throws(function() {
                    proj4('+proj=utm +zone=31', [null, 0]);
                }, 'coordinates must be finite numbers', 'should work');
            });
            it('should throw when passed NaN', function() {
                assert.throws(function() {
                    proj4('+proj=utm +zone=31', [0, NaN]);
                }, 'coordinates must be finite numbers', 'should work');
            });
            it('should throw when passed Infinity', function() {
                assert.throws(function() {
                    proj4('+proj=utm +zone=31', [Infinity, 0]);
                }, 'coordinates must be finite numbers', 'should work');
            });
            it('should throw when passed -Infinity', function() {
                assert.throws(function() {
                    proj4('+proj=utm +zone=31', [-Infinity, 0]);
                }, 'coordinates must be finite numbers', 'should work');
            });
        });
        describe('utility', function() {
            it('should have MGRS available in the proj4.util namespace', function() {
                assert.typeOf(proj4.mgrs, 'object', 'MGRS available in the proj4.util namespace');
            });
            it('should have fromMGRS method added to proj4.Point prototype', function() {
                assert.typeOf(proj4.Point.fromMGRS, 'function', 'fromMGRS method added to proj4.Point prototype');
            });
            it('should have toMGRS method added to proj4.Point prototype', function() {
                assert.typeOf(proj4.Point.prototype.toMGRS, 'function', 'toMGRS method added to proj4.Point prototype');
            });

            describe('First MGRS set', function() {
                const mgrs = '33UXP04';
                const point = proj4.Point.fromMGRS(mgrs);
                it('Longitude of point from MGRS correct.', function() {
                    assert.equal(point.x.toPrecision(7), '16.41450', 'Longitude of point from MGRS correct.');
                });
                it('Latitude of point from MGRS correct.', function() {
                    assert.equal(point.y.toPrecision(7), '48.24949', 'Latitude of point from MGRS correct.');
                });
                it('MGRS reference with highest accuracy correct.', function() {
                    assert.equal(point.toMGRS(), '33UXP0500444998', 'MGRS reference with highest accuracy correct.');
                });
                it('MGRS reference with 1-digit accuracy correct.', function() {
                    assert.equal(point.toMGRS(1), mgrs, 'MGRS reference with 1-digit accuracy correct.');
                });
            });
            describe('Second MGRS set', function() {
                const mgrs = '24XWT783908'; // near UTM zone border, so there are two ways to reference this
                const point = proj4.Point.fromMGRS(mgrs);
                it('Longitude of point from MGRS correct.', function() {
                    assert.equal(point.x.toPrecision(7), '-32.66433', 'Longitude of point from MGRS correct.');
                });
                it('Latitude of point from MGRS correct.', function() {
                    assert.equal(point.y.toPrecision(7), '83.62778', 'Latitude of point from MGRS correct.');
                });
                it('MGRS reference with 3-digit accuracy correct.', function() {
                    assert.equal(point.toMGRS(3), '25XEN041865', 'MGRS reference with 3-digit accuracy correct.');
                });
            });
            describe('Defs and Datum definition', function() {
                proj4.defs('EPSG:5514', '+proj=krovak +lat_0=49.5 +lon_0=24.83333333333333 +alpha=30.28813972222222 +k=0.9999 +x_0=0 +y_0=0 +ellps=bessel +pm=greenwich +units=m +no_defs +towgs84=570.8,85.7,462.8,4.998,1.587,5.261,3.56');
                const point = proj4.transform(proj4.Proj('WGS84'), proj4.Proj('EPSG:5514'),
                    proj4.toPoint([12.806988, 49.452262]));
                it('Longitude of point from WGS84 correct.', function() {
                    assert.equal(point.x.toPrecision(8), '-868208.61', 'Longitude of point from WGS84 correct.');
                });
                it('Latitude of point from WGS84 correct.', function() {
                    assert.equal(point.y.toPrecision(9), '-1095793.64', 'Latitude of point from WGS84 correct.');
                });
                const point2 = proj4.transform(proj4.Proj('WGS84'), proj4.Proj('EPSG:5514'),
                    proj4.toPoint([12.806988, 49.452262]));
                it('Longitude of point from WGS84 with second call for EPSG:5514 correct.', function() {
                    assert.equal(point2.x.toPrecision(8), '-868208.61', 'Longitude of point from WGS84 correct.');
                });
                it('Latitude of point from WGS84 with second call for EPSG:5514 correct.', function() {
                    assert.equal(point2.y.toPrecision(9), '-1095793.64', 'Latitude of point from WGS84 correct.');
                });
            });
        });

        describe('Nadgrids', function() {
            const tests = [
                [-44.382211538462, 40.3768, -44.380749, 40.377457], // just inside the lower limit
                [-87.617788, 59.623262, -87.617659, 59.623441], // just inside the upper limit
                [-44.5, 40.5, -44.498553, 40.500632], // inside the first square
                [-60, 50, -59.999192, 50.000058], // a general point towards the middle of the grid
                [0, 0, 0, 0] // fall back to null
            ];

            let converter;

            function initializeNadgrid(buffer) {
                proj4.nadgrid('ntv2', buffer);
                proj4.defs('ntv2_from', '+proj=longlat +ellps=clrk66 +nadgrids=@ignorable,ntv2,null');
                proj4.defs('ntv2_to', '+proj=longlat +datum=WGS84 +no_defs');
                converter = proj4('ntv2_from', 'ntv2_to');
            }

            before(function(done) {
                if (typeof XMLHttpRequest !== 'undefined') {
                    const xhr = new XMLHttpRequest();
                    xhr.open('GET', 'ntv2_0_downsampled.gsb', true);
                    xhr.responseType = 'arraybuffer';
                    xhr.addEventListener('load', function() {
                        initializeNadgrid(xhr.response);
                        done();
                    });
                    xhr.addEventListener('error', done);
                    xhr.send();
                } else if (typeof require === 'function') {
                    const fs = require('fs');
                    const path = require('path');
                    fs.readFile(path.join(__dirname, 'ntv2_0_downsampled.gsb'), function(err, data) {
                        if (err) {
                            done(err);
                        } else {
                            initializeNadgrid(data.buffer);
                            done();
                        }
                    });
                }
            });

            tests.forEach(function(test) {
                const fromLng = test[0];
                const fromLat = test[1];
                const toLng = test[2];
                const toLat = test[3];
                it('should interpolate ' + [fromLng, fromLat] + ' to ' + [toLng, toLat], function() {
                    const actual = converter.forward([fromLng, fromLat]);
                    assert.approximately(actual[0], toLng, 0.000001);
                    assert.approximately(actual[1], toLat, 0.000001);
                });
            });

            const inverseTests = [
                [-44.5, 40.5, -44.498553, 40.500632],
                [-60, 50, -59.999192, 50.000058]
            ];

            inverseTests.forEach(function(test) {
                const fromLng = test[0];
                const fromLat = test[1];
                const toLng = test[2];
                const toLat = test[3];
                it('should inverse interpolate ' + [toLng, toLat] + ' to ' + [fromLng, fromLat], function() {
                    const actual = converter.inverse([toLng, toLat]);
                    assert.approximately(actual[0], fromLng, 0.000001);
                    assert.approximately(actual[1], fromLat, 0.000001);
                });
            });
        });
    });
}
if (typeof process !== 'undefined' && process.toString() === '[object process]') {
    (function() {
        startTests(require('chai'), require('../../proj_library.js'), require('./testData'));
    })();
}
