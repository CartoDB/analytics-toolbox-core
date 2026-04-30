# Copyright (c) 2026, CARTO

from test_utils import run_query


QUADBIN_INDEX = 5209574053332910079

# Resolution-26 quadbin from the FROMLONGLAT highest-resolution test
QUADBIN_RES26 = 5306319089810035706

EXPECTED_CHILDREN_RES5 = sorted(
    [
        5214064458820747263,
        5214073254913769471,
        5214068856867258367,
        5214077652960280575,
    ]
)

EXPECTED_CHILDREN_RES7 = sorted(
    [
        5223067534906884095,
        5223067809784791039,
        5223068084662697983,
        5223068359540604927,
        5223068634418511871,
        5223068909296418815,
        5223069184174325759,
        5223069459052232703,
        5223069733930139647,
        5223070008808046591,
        5223070283685953535,
        5223070558563860479,
        5223070833441767423,
        5223071108319674367,
        5223071383197581311,
        5223071658075488255,
        5223071932953395199,
        5223072207831302143,
        5223072482709209087,
        5223072757587116031,
        5223073032465022975,
        5223073307342929919,
        5223073582220836863,
        5223073857098743807,
        5223074131976650751,
        5223074406854557695,
        5223074681732464639,
        5223074956610371583,
        5223075231488278527,
        5223075506366185471,
        5223075781244092415,
        5223076056121999359,
        5223076330999906303,
        5223076605877813247,
        5223076880755720191,
        5223077155633627135,
        5223077430511534079,
        5223077705389441023,
        5223077980267347967,
        5223078255145254911,
        5223078530023161855,
        5223078804901068799,
        5223079079778975743,
        5223079354656882687,
        5223079629534789631,
        5223079904412696575,
        5223080179290603519,
        5223080454168510463,
        5223080729046417407,
        5223081003924324351,
        5223081278802231295,
        5223081553680138239,
        5223081828558045183,
        5223082103435952127,
        5223082378313859071,
        5223082653191766015,
        5223082928069672959,
        5223083202947579903,
        5223083477825486847,
        5223083752703393791,
        5223084027581300735,
        5223084302459207679,
        5223084577337114623,
        5223084852215021567,
    ]
)

# 4^(9-4) = 4^5 = 1024
EXPECTED_CHILDREN_RES9_COUNT = 1024


def _children(quadbin, resolution):
    """Return TOCHILDREN result as a sorted list of ints."""
    rows = run_query(
        f"""SELECT COLUMN_VALUE
        FROM TABLE(@@ORA_SCHEMA@@.QUADBIN_TOCHILDREN({quadbin}, {resolution}))"""
    )
    return sorted(int(r[0]) for r in rows)


def test_quadbin_tochildren():
    assert _children(QUADBIN_INDEX, 5) == EXPECTED_CHILDREN_RES5


def test_quadbin_tochildren_multi_level():
    """Resolution 7 produces 4^3 = 64 children."""
    assert _children(QUADBIN_INDEX, 7) == EXPECTED_CHILDREN_RES7


def test_quadbin_tochildren_deep_recursion():
    """Resolution 9 produces 4^5 = 1024 children."""
    assert len(_children(QUADBIN_INDEX, 9)) == EXPECTED_CHILDREN_RES9_COUNT


def test_quadbin_tochildren_invalid_resolution_negative():
    """Negative resolution returns empty pipeline (NULL-on-invalid)."""
    assert _children(QUADBIN_INDEX, -1) == []


def test_quadbin_tochildren_resolution_overflow():
    """Resolution > 26 returns empty pipeline."""
    assert _children(QUADBIN_INDEX, 27) == []


def test_quadbin_tochildren_resolution_smaller_than_index():
    """Resolution coarser than input returns empty pipeline."""
    assert _children(QUADBIN_INDEX, 3) == []


def test_quadbin_tochildren_high_resolution():
    """TOCHILDREN works at maximum resolution (25 -> 26).

    Round-trip: the resolution-26 quadbin must appear among the 4 children
    of its resolution-25 parent.
    """
    parent_result = run_query(
        f'SELECT @@ORA_SCHEMA@@.QUADBIN_TOPARENT({QUADBIN_RES26}, 25) FROM DUAL'
    )
    parent_res25 = int(parent_result[0][0])

    children = _children(parent_res25, 26)
    assert len(children) == 4
    assert QUADBIN_RES26 in children
