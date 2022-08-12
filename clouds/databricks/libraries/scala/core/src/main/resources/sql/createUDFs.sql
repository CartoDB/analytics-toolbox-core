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
CREATE OR REPLACE FUNCTION st_box2DFromGeoHash as 'com.carto.analyticstoolbox.modules.parsers.ST_GeomFromGeoHash';
CREATE OR REPLACE FUNCTION st_geomFromGeoHash as 'com.carto.analyticstoolbox.modules.parsers.ST_GeomFromGeoHash';
CREATE OR REPLACE FUNCTION st_geomFromGeoJson as 'com.carto.analyticstoolbox.modules.parsers.ST_GeomFromGeoJson';
CREATE OR REPLACE FUNCTION st_geomFromWKB as 'com.carto.analyticstoolbox.modules.parsers.ST_GeomFromWKB';
CREATE OR REPLACE FUNCTION st_geomFromWKT as 'com.carto.analyticstoolbox.modules.parsers.ST_GeomFromWKT';
CREATE OR REPLACE FUNCTION st_geometryFromText as 'com.carto.analyticstoolbox.modules.parsers.ST_GeomFromWKT';
CREATE OR REPLACE FUNCTION st_lineFromText as 'com.carto.analyticstoolbox.modules.parsers.ST_LineFromText';
CREATE OR REPLACE FUNCTION st_mLineFromText as 'com.carto.analyticstoolbox.modules.parsers.ST_MLineFromText';
CREATE OR REPLACE FUNCTION st_mPointFromText as 'com.carto.analyticstoolbox.modules.parsers.ST_MPointFromText';
CREATE OR REPLACE FUNCTION st_mPolyFromText as 'com.carto.analyticstoolbox.modules.parsers.ST_MPolyFromText';
CREATE OR REPLACE FUNCTION st_pointFromGeoHash as 'com.carto.analyticstoolbox.modules.parsers.ST_PointFromGeoHash';
CREATE OR REPLACE FUNCTION st_pointFromText as 'com.carto.analyticstoolbox.modules.parsers.ST_PointFromText';
CREATE OR REPLACE FUNCTION st_pointFromWKB as 'com.carto.analyticstoolbox.modules.parsers.ST_PointFromWKB';
CREATE OR REPLACE FUNCTION st_polygonFromText as 'com.carto.analyticstoolbox.modules.parsers.ST_PolygonFromText';
-- Constructors
CREATE OR REPLACE FUNCTION st_makeBBOX as 'com.carto.analyticstoolbox.modules.constructors.ST_MakeBBOX';
CREATE OR REPLACE FUNCTION st_makeBox2D as 'com.carto.analyticstoolbox.modules.constructors.ST_MakeBox2D';
CREATE OR REPLACE FUNCTION st_makeLine as 'com.carto.analyticstoolbox.modules.constructors.ST_MakeLine';
CREATE OR REPLACE FUNCTION st_makePoint as 'com.carto.analyticstoolbox.modules.constructors.ST_MakePoint';
CREATE OR REPLACE FUNCTION st_makePointM as 'com.carto.analyticstoolbox.modules.constructors.ST_MakePointM';
CREATE OR REPLACE FUNCTION st_makePolygon as 'com.carto.analyticstoolbox.modules.constructors.ST_MakePolygon';
-- ST_POINT DOES NOT EXISTS, ALIAS CREATED
CREATE OR REPLACE FUNCTION st_point as 'com.carto.analyticstoolbox.modules.constructors.ST_MakePoint';
-- Measurements
CREATE OR REPLACE FUNCTION st_area as 'com.carto.analyticstoolbox.modules.measurements.ST_Area';
CREATE OR REPLACE FUNCTION st_distance as 'com.carto.analyticstoolbox.modules.measurements.ST_Distance';
CREATE OR REPLACE FUNCTION st_distanceSphere as 'com.carto.analyticstoolbox.modules.measurements.ST_DistanceSphere';
CREATE OR REPLACE FUNCTION st_length as 'com.carto.analyticstoolbox.modules.measurements.ST_Length';
CREATE OR REPLACE FUNCTION st_lengthSphere as 'com.carto.analyticstoolbox.modules.measurements.ST_LengthSphere';
-- Predicates
CREATE OR REPLACE FUNCTION st_contains as 'com.carto.analyticstoolbox.modules.predicates.ST_Contains';
CREATE OR REPLACE FUNCTION st_crosses as 'com.carto.analyticstoolbox.modules.predicates.ST_Crosses';
CREATE OR REPLACE FUNCTION st_disjoint as 'com.carto.analyticstoolbox.modules.predicates.ST_Disjoint';
CREATE OR REPLACE FUNCTION st_equals as 'com.carto.analyticstoolbox.modules.predicates.ST_Equals';
-- Not in the function list CREATE OR REPLACE FUNCTION st_intersection as 'com.carto.analyticstoolbox.core.ST_Intersection';
CREATE OR REPLACE FUNCTION st_intersects as 'com.carto.analyticstoolbox.modules.predicates.ST_Intersects';
CREATE OR REPLACE FUNCTION st_overlaps as 'com.carto.analyticstoolbox.modules.predicates.ST_Overlaps';
CREATE OR REPLACE FUNCTION st_relate as 'com.carto.analyticstoolbox.modules.predicates.ST_Relate';
CREATE OR REPLACE FUNCTION st_relateBool as 'com.carto.analyticstoolbox.modules.predicates.ST_RelateBool';
CREATE OR REPLACE FUNCTION st_touches as 'com.carto.analyticstoolbox.modules.predicates.ST_Touches';
CREATE OR REPLACE FUNCTION st_within as 'com.carto.analyticstoolbox.modules.predicates.ST_Within';
-- Transformations
