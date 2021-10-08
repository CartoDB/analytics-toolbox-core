from lib import quadkeyLib
from pytest import approx


def test_bbox():
    assert quadkeyLib.bbox(162) == approx([-90, 0, 0, 66.51326044311186])
    assert quadkeyLib.bbox(12070922) == approx(
        [
            -45,
            44.84029065139799,
            -44.6484375,
            45.089035564831015,
        ]
    )
    assert quadkeyLib.bbox(791040491538) == approx(
        [
            -45,
            44.999767019181284,
            -44.998626708984375,
            45.000738078290674,
        ]
    )
    assert quadkeyLib.bbox(12960460429066265) == approx(
        [
            -45,
            44.99999461263668,
            -44.99998927116394,
            45.00000219906961,
        ]
    )


def test_to_parent():
    for z in range(1, 30):
        for lat in range(-90, 91, 15):
            for lng in range(-180, 181, 15):
                quadint = quadkeyLib.quadint_from_location(lng, lat, z)
                current_parent = quadkeyLib.quadint_from_location(lng, lat, z - 1)
                assert current_parent == quadkeyLib.to_parent(quadint, z - 1)

    for z in range(5, 30):
        for lat in range(-90, 91, 15):
            for lng in range(-180, 181, 15):
                quadint = quadkeyLib.quadint_from_location(lng, lat, z)
                current_parent = quadkeyLib.quadint_from_location(lng, lat, z - 5)
                assert current_parent == quadkeyLib.to_parent(quadint, z - 5)

    for z in range(10, 30):
        for lat in range(-90, 91, 15):
            for lng in range(-180, 181, 15):
                quadint = quadkeyLib.quadint_from_location(lng, lat, z)
                current_parent = quadkeyLib.quadint_from_location(lng, lat, z - 10)
                assert current_parent == quadkeyLib.to_parent(quadint, z - 10)


def test_to_children():
    for z in range(0, 29):
        for lat in range(-90, 91, 15):
            for lng in range(-180, 181, 15):
                quadint = quadkeyLib.quadint_from_location(lng, lat, z)
                childs = quadkeyLib.to_children(quadint, z + 1)
                for element in childs:
                    assert quadkeyLib.to_parent(element, z) == quadint

    for z in range(0, 25):
        for lat in range(-90, 91, 15):
            for lng in range(-180, 181, 15):
                quadint = quadkeyLib.quadint_from_location(lng, lat, z)
                childs = quadkeyLib.to_children(quadint, z + 5)
                for element in childs:
                    assert quadkeyLib.to_parent(element, z) == quadint


def test_sibling():
    for z in range(0, 29):
        for lat in range(-90, 91, 15):
            for lng in range(-180, 181, 15):
                quadint = quadkeyLib.quadint_from_location(lng, lat, z)
                sibling_quadint = quadkeyLib.sibling(quadint, 'right')
                sibling_quadint = quadkeyLib.sibling(sibling_quadint, 'up')
                sibling_quadint = quadkeyLib.sibling(sibling_quadint, 'left')
                sibling_quadint = quadkeyLib.sibling(sibling_quadint, 'down')
                assert sibling_quadint == quadint


def test_kring():
    assert sorted(quadkeyLib.kring(162, 1)) == sorted(
        [
            130,
            162,
            194,
            2,
            258,
            290,
            322,
            34,
            66,
        ]
    )

    assert sorted(quadkeyLib.kring(12070922, 1)) == sorted(
        [
            12038122,
            12038154,
            12038186,
            12070890,
            12070922,
            12070954,
            12103658,
            12103690,
            12103722,
        ]
    )

    assert sorted(quadkeyLib.kring(791040491538, 1)) == sorted(
        [
            791032102898,
            791032102930,
            791032102962,
            791040491506,
            791040491538,
            791040491570,
            791048880114,
            791048880146,
            791048880178,
        ]
    )

    assert sorted(quadkeyLib.kring(12960460429066265, 1)) == sorted(
        [
            12960459355324409,
            12960459355324441,
            12960459355324473,
            12960460429066233,
            12960460429066265,
            12960460429066297,
            12960461502808057,
            12960461502808089,
            12960461502808121,
        ]
    )

    assert sorted(quadkeyLib.kring(12070922, 2)) == sorted(
        [
            12005322,
            12005354,
            12005386,
            12005418,
            12005450,
            12038090,
            12038122,
            12038154,
            12038186,
            12038218,
            12070858,
            12070890,
            12070922,
            12070954,
            12070986,
            12103626,
            12103658,
            12103690,
            12103722,
            12103754,
            12136394,
            12136426,
            12136458,
            12136490,
            12136522,
        ]
    )

    assert sorted(quadkeyLib.kring(791040491538, 3)) == sorted(
        [
            791015325618,
            791015325650,
            791015325682,
            791015325714,
            791015325746,
            791015325778,
            791015325810,
            791023714226,
            791023714258,
            791023714290,
            791023714322,
            791023714354,
            791023714386,
            791023714418,
            791032102834,
            791032102866,
            791032102898,
            791032102930,
            791032102962,
            791032102994,
            791032103026,
            791040491442,
            791040491474,
            791040491506,
            791040491538,
            791040491570,
            791040491602,
            791040491634,
            791048880050,
            791048880082,
            791048880114,
            791048880146,
            791048880178,
            791048880210,
            791048880242,
            791057268658,
            791057268690,
            791057268722,
            791057268754,
            791057268786,
            791057268818,
            791057268850,
            791065657266,
            791065657298,
            791065657330,
            791065657362,
            791065657394,
            791065657426,
            791065657458,
        ]
    )


def test_kring_distances():
    assert quadkeyLib.kring_distances(162, 1) == [
        {'distance': 0, 'index': 2},
        {'distance': 1, 'index': 34},
        {'distance': 2, 'index': 66},
        {'distance': 1, 'index': 130},
        {'distance': 1, 'index': 162},
        {'distance': 2, 'index': 194},
        {'distance': 2, 'index': 258},
        {'distance': 2, 'index': 290},
        {'distance': 2, 'index': 322},
    ]


def test_quadkey():
    tiles_per_level = 0
    for z in range(0, 30):
        if z == 0:
            tiles_per_level = 1
        else:
            tiles_per_level = 2 << (z - 1)

        x = 0
        y = 0
        zxy_decoded = quadkeyLib.zxy_from_quadint(
            quadkeyLib.quadint_from_quadkey(
                quadkeyLib.quadkey_from_quadint(quadkeyLib.quadint_from_zxy(z, x, y))
            )
        )
        z_decoded = zxy_decoded['z']
        x_decoded = zxy_decoded['x']
        y_decoded = zxy_decoded['y']
        assert z == z_decoded and x == x_decoded and y == y_decoded

        if z > 0:
            x = tiles_per_level / 2
            y = tiles_per_level / 2
            zxy_decoded = quadkeyLib.zxy_from_quadint(
                quadkeyLib.quadint_from_quadkey(
                    quadkeyLib.quadkey_from_quadint(
                        quadkeyLib.quadint_from_zxy(z, x, y)
                    )
                )
            )
            z_decoded = zxy_decoded['z']
            x_decoded = zxy_decoded['x']
            y_decoded = zxy_decoded['y']
            assert z == z_decoded and x == x_decoded and y == y_decoded

            x = tiles_per_level - 1
            y = tiles_per_level - 1
            zxy_decoded = quadkeyLib.zxy_from_quadint(
                quadkeyLib.quadint_from_quadkey(
                    quadkeyLib.quadkey_from_quadint(
                        quadkeyLib.quadint_from_zxy(z, x, y)
                    )
                )
            )
            z_decoded = zxy_decoded['z']
            x_decoded = zxy_decoded['x']
            y_decoded = zxy_decoded['y']
            assert z == z_decoded and x == x_decoded and y == y_decoded


def test_quadint():
    tiles_per_level = 0
    for z in range(0, 30):
        if z == 0:
            tiles_per_level = 1
        else:
            tiles_per_level = 2 << (z - 1)

        x = 0
        y = 0
        zxy_decoded = quadkeyLib.zxy_from_quadint(quadkeyLib.quadint_from_zxy(z, x, y))
        z_decoded = zxy_decoded['z']
        x_decoded = zxy_decoded['x']
        y_decoded = zxy_decoded['y']
        assert z == z_decoded and x == x_decoded and y == y_decoded

        if z > 0:
            x = tiles_per_level / 2
            y = tiles_per_level / 2
            zxy_decoded = quadkeyLib.zxy_from_quadint(
                quadkeyLib.quadint_from_zxy(z, x, y)
            )
            z_decoded = zxy_decoded['z']
            x_decoded = zxy_decoded['x']
            y_decoded = zxy_decoded['y']
            assert z == z_decoded and x == x_decoded and y == y_decoded

            x = tiles_per_level - 1
            y = tiles_per_level - 1
            zxy_decoded = quadkeyLib.zxy_from_quadint(
                quadkeyLib.quadint_from_zxy(z, x, y)
            )
            z_decoded = zxy_decoded['z']
            x_decoded = zxy_decoded['x']
            y_decoded = zxy_decoded['y']
            assert z == z_decoded and x == x_decoded and y == y_decoded
