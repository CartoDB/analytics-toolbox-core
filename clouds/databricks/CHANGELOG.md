# Changelog

CARTO Analytics Toolbox Core for Databricks.

All notable changes to this project will be documented in this file.

The format is inspired by [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [2022.10.19] - 2022-10-19

### All modules

#### Added

- Tasks to build installation packages

#### Changed

- Versioning uses YYYY.MM.DD format based on date now


## [2022.09.21] - 2022-09-21

### All modules

#### Added

- Add VERSION_CORE function

### Accessors

#### Changed

- Change type returned by ST_X and ST_Y to Double

## [2022.09.20] - 2022-09-20

### All modules

#### Changed

- Set default compression codec to snappy

## [2022.09.16] - 2022-09-16

### All modules

#### Added

- Add headers to functions that didn't have
- Add make rule to publis artifact in local and sonatype
- Add make rule to check and create headers

#### Changed

- change makefiles and sbt file to prepare the at advance

### Module parsers

### Fixed

- Fix the parser tests that had old user function names

## [2022.09.15] - 2022-09-15

### All modules

#### Changed

- The XY precission of the TWKBWriter is set to 5.

### Module formatters

#### Fixed

- Fix the doc of the transformers functions ST_ASLATLONTEXT and ST_ASTEXT.

## [2022.09.06] - 2022-09-06

### Module accessors

#### Fixed

- Fix the bug in ST_COORDDIM that was adding z coordinate to geometries.

### Module indexing

#### Fixed

- Fix the cast ClassCastException in ST_GEOMREPROJECT.

## [2022.09.01] - 2022-09-01

### All modules

#### Changed

- Refactor databricks cloud to adapt it to the new cloud structure

## [2022.08.29] - 2022-08-29

### Module indexing

#### Added

- Add ST_CRSFROMTEXT function.
- Add ST_EXTENTFROMGEOM function.
- Add ST_EXTENTTOGEOM function.
- Add ST_GEOMREPROJECT function.
- Add ST_MAKEEXTENT function.
- Add ST_PARTITIONCENTROID function.
- Add ST_Z2LATLON function.

### Module formatters

#### Added

- Add ST_ASTWKB function.

### Module parsers

#### Added

- Add ST_GEOMFROMWKT function.

### Module predicates

#### Added

- Add ST_COVERS function.

### Module transformations

#### Added

- Add ST_BUFFERPOINT function.
- Add ST_DIFFERENCE function.
- Add ST_SIMPLIFY function.

## [2022.08.19] - 2022-08-19

### Module accessors

#### Added

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

#### Added

- Add ST_MAKEBBOX function.
- Add ST_MAKEBOX2D function.
- Add ST_MAKELINE function.
- Add ST_MAKEPOINT function.
- Add ST_MAKEPOINTM function.
- Add ST_MAKEPOLYGON function.
- Add ST_POINT function.

### Module formatters

#### Added

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

#### Added

- Add ST_AREA function.
- Add ST_DISTANCE function.
- Add ST_DISTANCESPHERE function.
- Add ST_LENGTH function.
- Add ST_LENGTHSPHERE function.

### Module parsers

#### Added

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

#### Added

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

#### Added

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
