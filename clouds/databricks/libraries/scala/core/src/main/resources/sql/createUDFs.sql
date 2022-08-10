-- Accessors 
CREATE OR REPLACE FUNCTION ST_CoordDim as 'com.carto.analyticstoolbox.modules.accessors.ST_CoordDim';
CREATE OR REPLACE FUNCTION ST_Dimension as 'com.carto.analyticstoolbox.modules.accessors.ST_Dimension';
CREATE OR REPLACE FUNCTION ST_Envelope as 'com.carto.analyticstoolbox.modules.accessors.ST_Envelope';
CREATE OR REPLACE FUNCTION ST_GeometryN as 'com.carto.analyticstoolbox.modules.accessors.ST_GeometryN';
CREATE OR REPLACE FUNCTION ST_IsClosed as 'com.carto.analyticstoolbox.modules.accessors.ST_IsClosed';
CREATE OR REPLACE FUNCTION ST_IsCollection as 'com.carto.analyticstoolbox.modules.accessors.ST_IsCollection';
CREATE OR REPLACE FUNCTION ST_IsEmpty as 'com.carto.analyticstoolbox.modules.accessors.ST_IsEmpty';
CREATE OR REPLACE FUNCTION ST_IsGeomField as 'com.carto.analyticstoolbox.modules.accessors.ST_IsGeomField';
CREATE OR REPLACE FUNCTION ST_IsRing as 'com.carto.analyticstoolbox.modules.accessors.ST_IsRing';
CREATE OR REPLACE FUNCTION ST_IsSimple as 'com.carto.analyticstoolbox.modules.accessors.ST_IsSimple';
CREATE OR REPLACE FUNCTION ST_IsValid as 'com.carto.analyticstoolbox.modules.accessors.ST_IsValid';
CREATE OR REPLACE FUNCTION ST_NumGeometries as 'com.carto.analyticstoolbox.modules.accessors.ST_NumGeometries';
CREATE OR REPLACE FUNCTION ST_NumPoints as 'com.carto.analyticstoolbox.modules.accessors.ST_NumPoints';
CREATE OR REPLACE FUNCTION ST_PointN as 'com.carto.analyticstoolbox.modules.accessors.ST_PointN';
CREATE OR REPLACE FUNCTION ST_X as 'com.carto.analyticstoolbox.modules.accessors.ST_X';
CREATE OR REPLACE FUNCTION ST_Y as 'com.carto.analyticstoolbox.modules.accessors.ST_Y';
-- Parsers
CREATE OR REPLACE FUNCTION ST_GeomFromWKT as 'com.carto.analyticstoolbox.modules.parsers.ST_GeomFromWKT';
CREATE OR REPLACE FUNCTION st_geometryFromText as 'com.carto.analyticstoolbox.modules.parsers.ST_GeomFromWKT';
