-- Accessors 
CREATE OR REPLACE FUNCTION st_coordDim as 'com.carto.analyticstoolbox.modules.accessors.ST_CoordDim';
CREATE OR REPLACE FUNCTION st_dimension as 'com.carto.analyticstoolbox.modules.accessors.ST_Dimension';
CREATE OR REPLACE FUNCTION st_envelope as 'com.carto.analyticstoolbox.modules.accessors.ST_Envelope';
CREATE OR REPLACE FUNCTION st_geometryN as 'com.carto.analyticstoolbox.modules.accessors.ST_GeometryN';
CREATE OR REPLACE FUNCTION st_icClosed as 'com.carto.analyticstoolbox.modules.accessors.ST_IsClosed';
CREATE OR REPLACE FUNCTION st_isCollection as 'com.carto.analyticstoolbox.modules.accessors.ST_IsCollection';
CREATE OR REPLACE FUNCTION st_isEmpty as 'com.carto.analyticstoolbox.modules.accessors.ST_IsEmpty';
CREATE OR REPLACE FUNCTION st_isGeomField as 'com.carto.analyticstoolbox.modules.accessors.ST_IsGeomField';
CREATE OR REPLACE FUNCTION st_isRing as 'com.carto.analyticstoolbox.modules.accessors.ST_IsRing';
CREATE OR REPLACE FUNCTION st_isSimple as 'com.carto.analyticstoolbox.modules.accessors.ST_IsSimple';
CREATE OR REPLACE FUNCTION st_isValid as 'com.carto.analyticstoolbox.modules.accessors.ST_IsValid';
CREATE OR REPLACE FUNCTION st_numGeometries as 'com.carto.analyticstoolbox.modules.accessors.ST_NumGeometries';
CREATE OR REPLACE FUNCTION st_numPoints as 'com.carto.analyticstoolbox.modules.accessors.ST_NumPoints';
CREATE OR REPLACE FUNCTION st_pointN as 'com.carto.analyticstoolbox.modules.accessors.ST_PointN';
CREATE OR REPLACE FUNCTION st_x as 'com.carto.analyticstoolbox.modules.accessors.ST_X';
CREATE OR REPLACE FUNCTION st_y as 'com.carto.analyticstoolbox.modules.accessors.ST_Y';
-- Formatters
CREATE OR REPLACE FUNCTION st_asBinary as 'com.carto.analyticstoolbox.modules.formatters.ST_AsBinary';
CREATE OR REPLACE FUNCTION st_asGeoHash as 'com.carto.analyticstoolbox.modules.formatters.ST_AsGeoHash';
CREATE OR REPLACE FUNCTION st_asGeoJson as 'com.carto.analyticstoolbox.modules.formatters.ST_AsGeoJson';
CREATE OR REPLACE FUNCTION st_asLatLonText as 'com.carto.analyticstoolbox.modules.formatters.ST_AsLatLonText';
CREATE OR REPLACE FUNCTION st_asText as 'com.carto.analyticstoolbox.modules.formatters.ST_AsText';
CREATE OR REPLACE FUNCTION st_byteArray as 'com.carto.analyticstoolbox.modules.formatters.ST_ByteArray';
CREATE OR REPLACE FUNCTION st_castToGeometry as 'com.carto.analyticstoolbox.modules.formatters.ST_CastToGeometry';
CREATE OR REPLACE FUNCTION st_castToLineString as 'com.carto.analyticstoolbox.modules.formatters.ST_CastToLineString';
CREATE OR REPLACE FUNCTION st_castToPoint as 'com.carto.analyticstoolbox.modules.formatters.ST_CastToPoint';
CREATE OR REPLACE FUNCTION st_castToPoint as 'com.carto.analyticstoolbox.modules.formatters.ST_CastToPolygon';
-- Parsers
CREATE OR REPLACE FUNCTION st_geomFromWKT as 'com.carto.analyticstoolbox.modules.parsers.ST_GeomFromWKT';
CREATE OR REPLACE FUNCTION st_geometryFromText as 'com.carto.analyticstoolbox.modules.parsers.ST_GeomFromWKT';
