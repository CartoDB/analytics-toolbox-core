// ----------------------------
// -- Copyright (C) 2023 CARTO
// ----------------------------

export function removeNextDuplicates (coordinates) {
    const precision = 0.0000000000001;
    const uniqueCoordinates = [];

    for (let i = 0; i < coordinates.length; i++) {
        if (i == coordinates.length - 1 ||
            (Math.abs(coordinates[i][0] - coordinates[i+1][0]) > precision &&
             Math.abs(coordinates[i][1] - coordinates[i+1][1]) > precision)) {
            uniqueCoordinates.push(coordinates[i])
        }
    }

    return uniqueCoordinates;
}