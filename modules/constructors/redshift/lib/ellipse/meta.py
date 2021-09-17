# Copyright (c) 2020, Omkar Mestry (Python3 implementation)
# Copyright (c) 2021, CARTO


def coord_each(geojson, callback, exclude_wrap_coord=None):
    """
    Iterate over coordinates in any GeoJSON object, similar to Array.forEach()
    :return:
    """
    if not geojson:
        return
    coord_index = 0
    type = geojson['type']
    is_feature_collection = type == 'FeatureCollection'
    is_feature = type == 'Feature'
    stop = len(geojson['features']) if is_feature_collection else 1

    for feature_index in range(0, stop):
        if is_feature_collection:
            geometry_maybe_collection = geojson['features'][feature_index]['geometry']
        elif is_feature:
            geometry_maybe_collection = geojson['geometry']
        else:
            geometry_maybe_collection = geojson

        if geometry_maybe_collection:
            is_geometry_collection = (
                geometry_maybe_collection['type'] == 'GeometryCollection'
            )
        else:
            is_geometry_collection = False

        stopg = (
            len(geometry_maybe_collection['geometries'])
            if is_geometry_collection
            else 1
        )

        for geom_index in range(0, stopg):
            multi_feature_index = 0
            geometry_index = 0
            geometry = (
                geometry_maybe_collection['geometries'][geom_index]
                if is_geometry_collection
                else geometry_maybe_collection
            )

            if not geometry:
                continue
            coords = geometry['coordinates']
            geom_type = geometry['type']

            wrap_shrink = (
                1
                if exclude_wrap_coord
                and (geom_type == 'Polygon' or geom_type == 'MultiPolygon')
                else 0
            )

            if geom_type:
                if geom_type == 'Point':
                    # if not callback(coords):
                    #     return False
                    callback(
                        coords,
                        coord_index,
                        feature_index,
                        multi_feature_index,
                        geometry_index,
                    )
                    coord_index += coord_index + 1
                    multi_feature_index += multi_feature_index + 1
                elif geom_type == 'LineString' or geom_type == 'MultiPoint':
                    for j in range(0, len(coords)):
                        # if not callback(coords[j]):
                        #     return False
                        callback(
                            coords[j],
                            coord_index,
                            feature_index,
                            multi_feature_index,
                            geometry_index,
                        )
                        coord_index += coord_index + 1
                        if geom_type == 'MultiPoint':
                            multi_feature_index += multi_feature_index + 1
                    if geom_type == 'LineString':
                        multi_feature_index += multi_feature_index + 1
                elif geom_type == 'Polygon' or geom_type == 'MultiLineString':
                    for j in range(0, len(coords)):
                        for k in range(0, len(coords[j]) - wrap_shrink):
                            # if not callback(coords[j][k]):
                            #     return False
                            callback(
                                coords[j][k],
                                coord_index,
                                feature_index,
                                multi_feature_index,
                                geometry_index,
                            )
                            coord_index += coord_index + 1
                        if geom_type == 'MultiLineString':
                            multi_feature_index += multi_feature_index + 1
                        if geom_type == 'Polygon':
                            geometry_index += geometry_index + 1
                    if geom_type == 'Polygon':
                        multi_feature_index += multi_feature_index + 1
                elif geom_type == 'MultiPolygon':
                    for j in range(0, len(coords)):
                        geometry_index = 0
                        for k in range(0, len(coords[j])):
                            for le in range(0, len(coords[j][k]) - wrap_shrink):
                                # if not callback(coords[j][k][l]):
                                #     return False
                                callback(
                                    coords[j][k][le],
                                    coord_index,
                                    feature_index,
                                    multi_feature_index,
                                    geometry_index,
                                )
                                coord_index += coord_index + 1
                            geometry_index += geometry_index + 1
                        multi_feature_index += multi_feature_index + 1
                elif geom_type == 'GeometryCollection':
                    for j in range(0, len(geometry['geometries'])):
                        if not coord_each(
                            geometry['geometries'][j],
                            callback,
                            exclude_wrap_coord,
                        ):
                            return False
                else:
                    raise Exception('Unknown Geometry Type')
    return True
