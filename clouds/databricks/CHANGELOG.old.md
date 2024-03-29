# Changelog [old]

CARTO Analytics Toolbox Core for Databricks.

The format is inspired by [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [2022.10.19] - 2022-10-19

### All modules

#### Feature

- Tasks to build installation packages

#### Improvement

- Versioning uses YYYY.MM.DD format based on date now

## [2022.09.21] - 2022-09-21

### All modules

#### Feature

- Add VERSION_CORE function

### Accessors

#### Improvement

- Change type returned by ST_X and ST_Y to Double

## [2022.09.20] - 2022-09-20

### All modules

#### Improvement

- Set default compression codec to snappy

## [2022.09.16] - 2022-09-16

### All modules

#### Feature

- Add headers to functions that didn't have
- Add make rule to publis artifact in local and sonatype
- Add make rule to check and create headers

#### Improvement

- change makefiles and sbt file to prepare the at advance

### Module parsers

### Fixed

- Fix the parser tests that had old user function names

## [2022.09.15] - 2022-09-15

### All modules

#### Improvement

- The XY precission of the TWKBWriter is set to 5.

### Module formatters

#### Fix

- Fix the doc of the transformers functions ST_ASLATLONTEXT and ST_ASTEXT.

## [2022.09.06] - 2022-09-06

### Module accessors

#### Fix

- Fix the bug in ST_COORDDIM that was adding z coordinate to geometries.

### Module indexing

#### Fix

- Fix the cast ClassCastException in ST_GEOMREPROJECT.

## [2022.09.01] - 2022-09-01

### All modules

#### Improvement

- Refactor databricks cloud to adapt it to the new cloud structure

## [2022.08.29] - 2022-08-29

### Module indexing

#### Feature

- Add ST_CRSFROMTEXT function.
- Add ST_EXTENTFROMGEOM function.
- Add ST_EXTENTTOGEOM function.
- Add ST_GEOMREPROJECT function.
- Add ST_MAKEEXTENT function.
- Add ST_PARTITIONCENTROID function.
- Add ST_Z2LATLON function.

### Module formatters

#### Feature

- Add ST_ASTWKB function.

### Module parsers

#### Feature

- Add ST_GEOMFROMWKT function.

### Module predicates

#### Feature

- Add ST_COVERS function.

### Module transformations

#### Feature

- Add ST_BUFFERPOINT function.
- Add ST_DIFFERENCE function.
- Add ST_SIMPLIFY function.

## [2022.08.19] - 2022-08-19

### Module accessors

#### Feature

- Add ST_COORDDIM function.
- Add ST_DIMENSION function.
- Add ST_ENVELOPE function.
- Add ST_GEOMETRYN function.
- Add ST_ISCLOSED function.
- Add ST_ISCOLLECTION function.
- Add ST_ISEMPTY function.
- Add ST_ISGEOMFIELD function.
- Add ST_ISRING function.
- Add ST_ISSIMPLE function.
- Add ST_ISVALID function.
- Add ST_NUMGEOMETRIES function.
- Add ST_NUMPOINTS function.
- Add ST_POINTN function.
- Add ST_Y function.
- Add ST_X function.

### Module constructors

#### Feature

- Add ST_MAKEBBOX function.
- Add ST_MAKEBOX2D function.
- Add ST_MAKELINE function.
- Add ST_MAKEPOINT function.
- Add ST_MAKEPOINTM function.
- Add ST_MAKEPOLYGON function.
- Add ST_POINT function.

### Module formatters

#### Feature

- Add ST_ASBINARY function.
- Add ST_ASGEOHASH function.
- Add ST_ASGEOJSON function.
- Add ST_ASLATLONTEXT function.
- Add ST_ASTEXT function.
- Add ST_BYTEARRAY function.
- Add ST_CASTTOGEOMETRY function.
- Add ST_CASTTOLINESTRING function.
- Add ST_CASTTOPOINT function.
- Add ST_CASTTOPOLYGON function.

### Module measurements

#### Feature

- Add ST_AREA function.
- Add ST_DISTANCE function.
- Add ST_DISTANCESPHERE function.
- Add ST_LENGTH function.
- Add ST_LENGTHSPHERE function.

### Module parsers

#### Feature

- Add ST_BOX2DFROMGEOHASH function.
- Add ST_GEOMETRYFROMTEXT function.
- Add ST_GEOMFROMGEOHASH function.
- Add ST_GEOMFROMGEOJSON function.
- Add ST_GEOMFROMWKB function.
- Add ST_GEOMFROMWKT function.
- Add ST_LINEFROMTEXT function.
- Add ST_MLINEFROMTEXT function.
- Add ST_MPOINTFROMTEXT function.
- Add ST_MPOLYFROMTEXT function.
- Add ST_POINTFROMGEOHASH function.
- Add ST_POINTFROMTEXT function.
- Add ST_POINTFROMWKB function.
- Add ST_POLYGONFROMTEXT function.

### Module predicates

#### Feature

- Add ST_CONTAINS function.
- Add ST_CROSSES function.
- Add ST_DISJOINT function.
- Add ST_EQUALS function.
- Add ST_INTERSECTS function.
- Add ST_OVERLAPS function.
- Add ST_RELATE function.
- Add ST_RELATEBOOL function.
- Add ST_TOUCHES function.
- Add ST_WITHIN function.

### Module transformations

#### Feature

- Add ST_ANTIMERIDIANSAFEGEOM function.
- Add ST_BOUNDARY function.
- Add ST_CENTROID function.
- Add ST_CLOSESTPOINT function.
- Add ST_CONVEXHULL function.
- Add ST_EXTERIORRING function.
- Add ST_IDLSAFEGEOM function.
- Add ST_INTERIORRINGN function.
- Add ST_INTERSECTION function.
- Add ST_TRANSLATE function.
