"""
CARTO Analytics Toolbox - QUADBIN_POLYFILL
Lambda handler for Redshift external function

This function fills a geometry with quadbin indices at a given resolution.
"""

import json
from typing import List, Optional, Dict, Any


def quadbin_from_zxy(z: int, x: int, y: int) -> Optional[int]:
    """
    Convert z/x/y tile coordinates to quadbin index.

    Args:
        z: Zoom level (0-26)
        x: Tile x coordinate
        y: Tile y coordinate

    Returns:
        Quadbin index as integer, or None if invalid
    """
    if z < 0 or z > 26:
        return None
    if x < 0 or x >= (1 << z) or y < 0 or y >= (1 << z):
        return None

    # Quadbin encoding: interleave x and y bits
    quadbin = z
    for i in range(z):
        bit_x = (x >> (z - i - 1)) & 1
        bit_y = (y >> (z - i - 1)) & 1
        quadbin = (quadbin << 2) | (bit_y << 1) | bit_x

    return quadbin


def polyfill_geometry(geom_wkt: str, resolution: int) -> List[int]:
    """
    Fill a geometry with quadbins at the given resolution.

    Args:
        geom_wkt: WKT string representation of geometry
        resolution: Quadbin resolution level (0-26)

    Returns:
        List of quadbin indices covering the geometry
    """
    # TODO: Implement proper WKT parsing and polyfill algorithm
    # This is a simplified placeholder implementation
    # In production, this would:
    # 1. Parse WKT geometry
    # 2. Get bounding box
    # 3. Generate quadbins that intersect the geometry
    # 4. Return array of quadbin indices

    # For now, return a sample quadbin at the center
    if resolution < 0 or resolution > 26:
        return []

    # Sample implementation - returns a single quadbin
    center_tile = (1 << (resolution - 1)) if resolution > 0 else 0
    quadbin = quadbin_from_zxy(resolution, center_tile, center_tile)

    return [quadbin] if quadbin is not None else []


def lambda_handler(event: Dict[str, Any], context: Any = None) -> Dict[str, Any]:
    """
    AWS Lambda handler for Redshift external function.

    Redshift sends batches of rows in this format:
    {
      "request_id": "...",
      "cluster": "...",
      "user": "...",
      "database": "...",
      "external_function": "...",
      "query_id": ...,
      "num_records": N,
      "arguments": [[geom1, res1], [geom2, res2], ...]
    }

    Must return (per AWS documentation):
    {
      "results": [result1, result2, ...]
    }

    For errors, can return:
    {
      "error_msg": "Error message",
      "num_records": 0,
      "results": []
    }

    Args:
        event: Event from Redshift containing arguments and num_records
        context: Lambda context (unused)

    Returns:
        Response dict with results or error
    """
    try:
        arguments = event.get("arguments", [])
        num_records = event.get("num_records", len(arguments))

        results = []

        for i, row in enumerate(arguments):
            try:
                if row is None or len(row) < 2:
                    results.append(None)
                    continue

                geom, resolution = row[0], row[1]

                # Handle null inputs
                if geom is None or resolution is None:
                    results.append(None)
                    continue

                # Process the geometry
                quadbins = polyfill_geometry(str(geom), int(resolution))
                # Return as JSON string - external function returns VARCHAR
                result_str = json.dumps(quadbins)
                results.append(result_str)

            except Exception as row_error:
                # Log error to CloudWatch but continue processing other rows
                print(f"Error processing row {i}: {row_error}")
                results.append(None)

        # Ensure we return exactly num_records results
        # Pad with None if needed
        while len(results) < num_records:
            results.append(None)

        response = {
            "success": True,
            "num_records": num_records,
            "results": results[:num_records],  # Trim to exact num_records
        }
        # IMPORTANT: Redshift expects the response as a JSON STRING, not a dict
        return json.dumps(response)

    except Exception as e:
        # Batch-level error
        return json.dumps(
            {
                "success": False,
                "error_msg": f"Error processing batch: {str(e)}",
                "num_records": 0,
                "results": [],
            }
        )
