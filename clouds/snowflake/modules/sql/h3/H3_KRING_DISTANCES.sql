---------------------------------
-- Copyright (C) 2021-2024 CARTO
---------------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._H3_KRING_DISTANCES
(origin STRING, hexarray ARRAY)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$

  @@SF_LIBRARY_H3_KRING_DISTANCES@@
  @@SF_LIBRARY_H3_ISPENTAGON@@

  let ranges = [];
  const arrayLength = HEXARRAY.length;

  if (arrayLength > 0) {
    // Initialize the first ring.
    ranges.push({ start: 0, end: 1 });
  }

  // Start from the first ring and find ranges for each ring until the array end.
  let k = 1;
  while (true) {
    // The start index for the current ring is the end index of the previous ring
    const start = ranges[k - 1].end;
    // The end index for the current ring, using the formula and adjusting for 0-based index.
    const end = Math.min(arrayLength, 1 + 3 * k * (k + 1));

    ranges.push({ start, end });

    // If the end index reaches or exceeds the array length, stop the loop.
    if (end >= arrayLength - 1) {
      break;
    }

    k++; // Move to the next ring.
  }
  var results = []

  const hasPentagon = HEXARRAY.some(hex => h3IspentagonLib.h3IsPentagon(hex))
  let checkEach = hasPentagon
    
  ranges.forEach((range, expectedDistance) => {
    let hexBlock = HEXARRAY.slice(range.start, range.end)

    for (let i = 0; i < hexBlock.length; i++) {
      let hex = hexBlock[i]	
      let distance = checkEach ? h3KringDistancesLib.h3Distance(ORIGIN, hex) : expectedDistance
      if (distance != expectedDistance) {
        checkEach = true;
	--i
	continue;
      }
      else if (!hasPentagon && distance == expectedDistance) {
        checkEach = false;
      }
      results.push({"index": hex, "distance": distance})
    }
  })

  return results
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_KRING_DISTANCES
(origin STRING, size INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    CASE
        WHEN SIZE IS NULL or SIZE < 0 THEN @@SF_SCHEMA@@._CARTO_ARRAY_ERROR('Invalid input size')
        WHEN NOT @@SF_SCHEMA@@.H3_ISVALID(ORIGIN) THEN @@SF_SCHEMA@@._CARTO_ARRAY_ERROR('Invalid input origin')
	ELSE @@SF_SCHEMA@@._H3_KRING_DISTANCES(origin, H3_GRID_DISK(ORIGIN, SIZE))
    END
$$;
