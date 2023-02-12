# flake8: noqa

# H3 Pure Python port of h3lib https://github.com/uber/h3
# @jgoizueta

import sys
import math
import copy

# constants ---------------------------------------------------

EPSILON = sys.float_info.epsilon

M_PI = 3.14159265358979323846
# pi / 2.0
M_PI_2 = 1.5707963267948966
# 2.0 * PI
M_2PI = 6.28318530717958647692528676655900576839433
# pi / 180
M_PI_180 = 0.0174532925199432957692369076848861271111
# pi * 180
M_180_PI = 57.29577951308232087679815481410517033240547

# threshold epsilon
EPSILON = 0.0000000000000001
# sqrt(3) / 2.0
M_SQRT3_2 = 0.8660254037844386467637231707529361834714
# sin(60')
M_SIN60 = M_SQRT3_2

# rotation angle between Class II and Class III resolution ax
# (asin(sqrt(3.0 / 28.0)))
M_AP7_ROT_RADS = 0.333473172251832115336090755351601070065900389

# sin(M_AP7_ROT_RADS)
M_SIN_AP7_ROT = 0.3273268353539885718950318

# cos(M_AP7_ROT_RADS)
M_COS_AP7_ROT = 0.9449111825230680680167902

# square root of 7
M_SQRT7 = 2.6457513110645905905016157536392604257102

# earth radius in kilometers using WGS84 authalic radius
EARTH_RADIUS_KM = 6371.007180918475

# scaling factor from hex2d resolution 0 unit leng
# (or distance between adjacent cell center points
# on the plane) to gnomonic unit length.
RES0_U_GNOMONIC = 0.38196601125010500003

# max H3 resolution; H3 version 1 has 16 resolutions, numbered 0 through 15
MAX_H3_RES = 15

# The number of faces on an icosahedron
NUM_ICOSA_FACES = 20
# The number of H3 base cells
NUM_BASE_CELLS = 122
# The number of vertices in a hexagon
NUM_HEX_VERTS = 6
# The number of vertices in a pentagon
NUM_PENT_VERTS = 5
# The number of pentagons per resolution *
NUM_PENTAGONS = 12

# H3 index modes
H3_CELL_MODE = 1
H3_DIRECTEDEDGE_MODE = 2
H3_EDGE_MODE = 3
H3_VERTEX_MODE = 4

# coordijk ---------------------------------------------------

#  @struct CoordIJK
# @brief IJK hexagon coordinates
# Each axis is spaced 120 degrees apart.
class CoordIJK:
    def __init__(self, i=0, j=0, k=0):
        self.i = i
        self.j = j
        self.k = k


# @brief CoordIJK unit vectors corresponding to the 7 H3 digits.
# TODO: avoid mutable objects in tables
UNIT_VECS = [
    CoordIJK(),  # direction 0
    CoordIJK(k=1),  # direction 1
    CoordIJK(j=1),  # direction 2
    CoordIJK(0, 1, 1),  # direction 3
    CoordIJK(i=1),  # direction 4
    CoordIJK(1, 0, 1),  # direction 5
    CoordIJK(1, 1, 0),  # direction 6
]

# @brief H3 digit representing ijk+ axes direction.
# Values will be within the lowest 3 bits of an integer.

# H3 digit in center
DIRECTION_CENTER_DIGIT = 0
# H3 digit in k-axes direction
DIRECTION_K_AXES_DIGIT = 1
# H3 digit in j-axes direction
DIRECTION_J_AXES_DIGIT = 2
# H3 digit in j == k direction
DIRECTION_JK_AXES_DIGIT = DIRECTION_J_AXES_DIGIT | DIRECTION_K_AXES_DIGIT  # 3
# H3 digit in i-axes direction */
DIRECTION_I_AXES_DIGIT = 4
# H3 digit in i == k direction */
DIRECTION_IK_AXES_DIGIT = DIRECTION_I_AXES_DIGIT | DIRECTION_K_AXES_DIGIT  # 5
# H3 digit in i == j direction */
DIRECTION_IJ_AXES_DIGIT = DIRECTION_I_AXES_DIGIT | DIRECTION_J_AXES_DIGIT  # 6
# H3 digit in the invalid direction */
DIRECTION_INVALID_DIGIT = 7
# Valid digits will be less than this value. Same value as INVALID_DIGIT.
DIRECTION_NUM_DIGITS = DIRECTION_INVALID_DIGIT
# Child digit which is skipped for pentagons */
DIRECTION_PENTAGON_SKIPPED_DIGIT = DIRECTION_K_AXES_DIGIT  # 1

# Add two ijk coordinates.
# @param h1 The first set of ijk coordinates.
# @param h2 The second set of ijk coordinates.
# @param sum The sum of the two sets of ijk coordinates.
# TODO: make it more idiomatic by changing mutator method to functional style:
# def_ijkAdd(h1, h2): return CoordIJK(h1.i + h2.i, h1.j + h2.j, h1.k + h2.k)
def _ijkAdd(h1, h2, sum):
    sum.i = h1.i + h2.i
    sum.j = h1.j + h2.j
    sum.k = h1.k + h2.k


# Subtract two ijk coordinates.
# @param h1 The first set of ijk coordinates.
# @param h2 The second set of ijk coordinates.
# @param diff The difference of the two sets of ijk coordinates (h1 - h2).
def _ijkSub(h1, h2, diff):
    diff.i = h1.i - h2.i
    diff.j = h1.j - h2.j
    diff.k = h1.k - h2.k


# Uniformly scale ijk coordinates by a scalar. Works in place.
# @param c The ijk coordinates to scale.
# @param factor The scaling factor.
def _ijkScale(c, factor):
    c.i *= factor
    c.j *= factor
    c.k *= factor


# Normalizes ijk coordinates by setting the components to the smallest possible
# values. Works in place.
# @param c The ijk coordinates to normalize.
def _ijkNormalize(c):
    # remove any negative values
    if c.i < 0:
        c.j -= c.i
        c.k -= c.i
        c.i = 0

    if c.j < 0:
        c.i -= c.j
        c.k -= c.j
        c.j = 0

    if c.k < 0:
        c.i -= c.k
        c.j -= c.k
        c.k = 0

    # remove the min value if needed
    min = c.i
    if c.j < min:
        min = c.j
    if c.k < min:
        min = c.k
    if min > 0:
        c.i -= min
        c.j -= min
        c.k -= min


# Find the normalized ijk coordinates of the hex in the specified digit
# direction from the specified ijk coordinates. Works in place.
# @param ijk The ijk coordinates.
# @param digit The digit direction from the original ijk coordinates.
def _neighbor(ijk, digit):
    if digit > DIRECTION_CENTER_DIGIT and digit < DIRECTION_NUM_DIGITS:
        _ijkAdd(ijk, UNIT_VECS[digit], ijk)
        _ijkNormalize(ijk)


# Rotates ijk coordinates 60 degrees counter-clockwise. Works in place.
# @param ijk The ijk coordinates.
def _ijkRotate60ccw(ijk):
    # unit vector rotations
    iVec = CoordIJK(1, 1, 0)
    jVec = CoordIJK(0, 1, 1)
    kVec = CoordIJK(1, 0, 1)

    _ijkScale(iVec, ijk.i)
    _ijkScale(jVec, ijk.j)
    _ijkScale(kVec, ijk.k)

    _ijkAdd(iVec, jVec, ijk)
    _ijkAdd(ijk, kVec, ijk)

    _ijkNormalize(ijk)


# Rotates ijk coordinates 60 degrees clockwise. Works in place.
# @param ijk The ijk coordinates.
def _ijkRotate60cw(ijk):
    # unit vector rotations
    iVec = CoordIJK(1, 0, 1)
    jVec = CoordIJK(1, 1, 0)
    kVec = CoordIJK(0, 1, 1)

    _ijkScale(iVec, ijk.i)
    _ijkScale(jVec, ijk.j)
    _ijkScale(kVec, ijk.k)

    _ijkAdd(iVec, jVec, ijk)
    _ijkAdd(ijk, kVec, ijk)

    _ijkNormalize(ijk)


# Rotates indexing digit 60 degrees counter-clockwise. Returns result.
# @param digit Indexing digit (between 1 and 6 inclusive)
def _rotate60ccw(digit):
    if digit == DIRECTION_K_AXES_DIGIT:
        return DIRECTION_IK_AXES_DIGIT
    elif digit == DIRECTION_IK_AXES_DIGIT:
        return DIRECTION_I_AXES_DIGIT
    elif digit == DIRECTION_I_AXES_DIGIT:
        return DIRECTION_IJ_AXES_DIGIT
    elif digit == DIRECTION_IJ_AXES_DIGIT:
        return DIRECTION_J_AXES_DIGIT
    elif digit == DIRECTION_J_AXES_DIGIT:
        return DIRECTION_JK_AXES_DIGIT
    elif digit == DIRECTION_JK_AXES_DIGIT:
        return DIRECTION_K_AXES_DIGIT
    else:
        return digit


# Rotates indexing digit 60 degrees clockwise. Returns result.
# @param digit Indexing digit (between 1 and 6 inclusive)
def _rotate60cw(digit):
    if digit == DIRECTION_K_AXES_DIGIT:
        return DIRECTION_JK_AXES_DIGIT
    elif digit == DIRECTION_JK_AXES_DIGIT:
        return DIRECTION_J_AXES_DIGIT
    elif digit == DIRECTION_KJ_AXES_DIGIT:
        return DIRECTION_IJ_AXES_DIGIT
    elif digit == DIRECTION_IJ_AXES_DIGIT:
        return DIRECTION_I_AXES_DIGIT
    elif digit == DIRECTION_I_AXES_DIGIT:
        return DIRECTION_IK_AXES_DIGIT
    elif digit == DIRECTION_IK_AXES_DIGIT:
        return DIRECTION_K_AXES_DIGIT
    else:
        return digit


# Find the normalized ijk coordinates of the indexing parent of a cell in a
# counter-clockwise aperture 7 grid. Works in place.
# @param ijk CoordIJK The ijk coordinates.
def _upAp7(ijk):
    # convert to CoordIJ
    i = ijk.i - ijk.k
    j = ijk.j - ijk.k

    ijk.i = round((3 * i - j) / 7.0)
    ijk.j = round((i + 2 * j) / 7.0)
    ijk.k = 0
    _ijkNormalize(ijk)


# Find the normalized ijk coordinates of the indexing parent of a cell in a
# clockwise aperture 7 grid. Works in place.
# @param CoordIJK ijk The ijk coordinates.
def _upAp7r(ijk):
    # convert to CoordIJ
    i = ijk.i - ijk.k
    j = ijk.j - ijk.k

    ijk.i = round((2 * i + j) / 7.0)
    ijk.j = round((3 * j - i) / 7.0)
    ijk.k = 0
    _ijkNormalize(ijk)


# Find the normalized ijk coordinates of the hex centered on the indicated
# hex at the next finer aperture 7 counter-clockwise resolution. Works in
# place.
# @param ijk The ijk coordinates.
def _downAp7(ijk):
    # res r unit vectors in res r+1
    iVec = CoordIJK(3, 0, 1)
    jVec = CoordIJK(1, 3, 0)
    kVec = CoordIJK(0, 1, 3)

    _ijkScale(iVec, ijk.i)
    _ijkScale(jVec, ijk.j)
    _ijkScale(kVec, ijk.k)

    _ijkAdd(iVec, jVec, ijk)
    _ijkAdd(ijk, kVec, ijk)

    _ijkNormalize(ijk)


# Find the normalized ijk coordinates of the hex centered on the indicated
# hex at the next finer aperture 7 clockwise resolution. Works in place.
# @param ijk The ijk coordinates.
def _downAp7r(ijk):
    # res r unit vectors in res r+1
    iVec = CoordIJK(3, 1, 0)
    jVec = CoordIJK(0, 3, 1)
    kVec = CoordIJK(1, 0, 3)

    _ijkScale(iVec, ijk.i)
    _ijkScale(jVec, ijk.j)
    _ijkScale(kVec, ijk.k)

    _ijkAdd(iVec, jVec, ijk)
    _ijkAdd(ijk, kVec, ijk)

    _ijkNormalize(ijk)


# faceijk -----------------------------------------------------

# @struct FaceIJK
# @brief Face number and ijk coordinates on that face-centered coordinate
# system
class FaceIJK:
    def __init__(self, face, i, j, k):
        self.face = face
        self.coord = CoordIJK(i, j, k)


#  @struct FaceOrientIJK
# @brief Information to transform into an adjacent face IJK system
class FaceOrientIJK:
    def __init__(self, face=0, translate=CoordIJK(), ccwRot60=0):
        self.face = face  # int face number
        self.translate = (
            translate  # CoordIJK res 0 translation relative to primary face
        )
        self.ccwRot60 = (
            ccwRot60  # int number of 60 degree ccw rotations relative to primary face
        )


# indexes for faceNeighbors table
# IJ quadrant faceNeighbors table direction
IJ = 1
# KI quadrant faceNeighbors table direction */
KI = 2
# JK quadrant faceNeighbors table direction */
JK = 3

# Invalid face index
INVALID_FACE = -1

# Digit representing overage type
OVERAGE_NO_OVERAGE = 0
# On face edge (only occurs on substrate grids)
OVERAGE_FACE_EDGE = 1
# Overage on new face interior
OVERAGE_NEW_FACE = 2

# @brief overage distance table
maxDimByCIIres = [
    2,  # res  0
    -1,  # res  1
    14,  # res  2
    -1,  # res  3
    98,  # res  4
    -1,  # res  5
    686,  # res  6
    -1,  # res  7
    4802,  # res  8
    -1,  # res  9
    33614,  # res 10
    -1,  # res 11
    235298,  # res 12
    -1,  # res 13
    1647086,  # res 14
    -1,  # res 15
    11529602,  # res 16
]

# @brief unit scale distance table
unitScaleByCIIres = [
    1,  # res  0
    -1,  # res  1
    7,  # res  2
    -1,  # res  3
    49,  # res  4
    -1,  # res  5
    343,  # res  6
    -1,  # res  7
    2401,  # res  8
    -1,  # res  9
    16807,  # res 10
    -1,  # res 11
    117649,  # res 12
    -1,  # res 13
    823543,  # res 14
    -1,  # res 15
    5764801,  # res 16
]

# @brief Definition of which faces neighbor each other.
# TODO: avoid mutable objects in tables
faceNeighbors = [
    [
        # face 0
        FaceOrientIJK(0, CoordIJK(0, 0, 0), 0),  # central face
        FaceOrientIJK(4, CoordIJK(2, 0, 2), 1),  # ij quadrant
        FaceOrientIJK(1, CoordIJK(2, 2, 0), 5),  # ki quadrant
        FaceOrientIJK(5, CoordIJK(0, 2, 2), 3),  # jk quadrant
    ],
    [
        # face 1
        FaceOrientIJK(1, CoordIJK(0, 0, 0), 0),  # central face
        FaceOrientIJK(0, CoordIJK(2, 0, 2), 1),  # ij quadrant
        FaceOrientIJK(2, CoordIJK(2, 2, 0), 5),  # ki quadrant
        FaceOrientIJK(6, CoordIJK(0, 2, 2), 3),  # jk quadrant
    ],
    [
        # face 2
        FaceOrientIJK(2, CoordIJK(0, 0, 0), 0),  # central face
        FaceOrientIJK(1, CoordIJK(2, 0, 2), 1),  # ij quadrant
        FaceOrientIJK(3, CoordIJK(2, 2, 0), 5),  # ki quadrant
        FaceOrientIJK(7, CoordIJK(0, 2, 2), 3),  # jk quadrant
    ],
    [
        # face 3
        FaceOrientIJK(3, CoordIJK(0, 0, 0), 0),  # central face
        FaceOrientIJK(2, CoordIJK(2, 0, 2), 1),  # ij quadrant
        FaceOrientIJK(4, CoordIJK(2, 2, 0), 5),  # ki quadrant
        FaceOrientIJK(8, CoordIJK(0, 2, 2), 3),  # jk quadrant
    ],
    [
        # face 4
        FaceOrientIJK(4, CoordIJK(0, 0, 0), 0),  # central face
        FaceOrientIJK(3, CoordIJK(2, 0, 2), 1),  # ij quadrant
        FaceOrientIJK(0, CoordIJK(2, 2, 0), 5),  # ki quadrant
        FaceOrientIJK(9, CoordIJK(0, 2, 2), 3),  # jk quadrant
    ],
    [
        # face 5
        FaceOrientIJK(5, CoordIJK(0, 0, 0), 0),  # central face
        FaceOrientIJK(10, CoordIJK(2, 2, 0), 3),  # ij quadrant
        FaceOrientIJK(14, CoordIJK(2, 0, 2), 3),  # ki quadrant
        FaceOrientIJK(0, CoordIJK(0, 2, 2), 3),  # jk quadrant
    ],
    [
        # face 6
        FaceOrientIJK(6, CoordIJK(0, 0, 0), 0),  # central face
        FaceOrientIJK(11, CoordIJK(2, 2, 0), 3),  # ij quadrant
        FaceOrientIJK(10, CoordIJK(2, 0, 2), 3),  # ki quadrant
        FaceOrientIJK(1, CoordIJK(0, 2, 2), 3),  # jk quadrant
    ],
    [
        # face 7
        FaceOrientIJK(7, CoordIJK(0, 0, 0), 0),  # central face
        FaceOrientIJK(12, CoordIJK(2, 2, 0), 3),  # ij quadrant
        FaceOrientIJK(11, CoordIJK(2, 0, 2), 3),  # ki quadrant
        FaceOrientIJK(2, CoordIJK(0, 2, 2), 3),  # jk quadrant
    ],
    [
        # face 8
        FaceOrientIJK(8, CoordIJK(0, 0, 0), 0),  # central face
        FaceOrientIJK(13, CoordIJK(2, 2, 0), 3),  # ij quadrant
        FaceOrientIJK(12, CoordIJK(2, 0, 2), 3),  # ki quadrant
        FaceOrientIJK(3, CoordIJK(0, 2, 2), 3),  # jk quadrant
    ],
    [
        # face 9
        FaceOrientIJK(9, CoordIJK(0, 0, 0), 0),  # central face
        FaceOrientIJK(14, CoordIJK(2, 2, 0), 3),  # ij quadrant
        FaceOrientIJK(13, CoordIJK(2, 0, 2), 3),  # ki quadrant
        FaceOrientIJK(4, CoordIJK(0, 2, 2), 3),  # jk quadrant
    ],
    [
        # face 10
        FaceOrientIJK(10, CoordIJK(0, 0, 0), 0),  # central face
        FaceOrientIJK(5, CoordIJK(2, 2, 0), 3),  # ij quadrant
        FaceOrientIJK(6, CoordIJK(2, 0, 2), 3),  # ki quadrant
        FaceOrientIJK(15, CoordIJK(0, 2, 2), 3),  # jk quadrant
    ],
    [
        # face 11
        FaceOrientIJK(11, CoordIJK(0, 0, 0), 0),  # central face
        FaceOrientIJK(6, CoordIJK(2, 2, 0), 3),  # ij quadrant
        FaceOrientIJK(7, CoordIJK(2, 0, 2), 3),  # ki quadrant
        FaceOrientIJK(16, CoordIJK(0, 2, 2), 3),  # jk quadrant
    ],
    [
        # face 12
        FaceOrientIJK(12, CoordIJK(0, 0, 0), 0),  # central face
        FaceOrientIJK(7, CoordIJK(2, 2, 0), 3),  # ij quadrant
        FaceOrientIJK(8, CoordIJK(2, 0, 2), 3),  # ki quadrant
        FaceOrientIJK(17, CoordIJK(0, 2, 2), 3),  # jk quadrant
    ],
    [
        # face 13
        FaceOrientIJK(13, CoordIJK(0, 0, 0), 0),  # central face
        FaceOrientIJK(8, CoordIJK(2, 2, 0), 3),  # ij quadrant
        FaceOrientIJK(9, CoordIJK(2, 0, 2), 3),  # ki quadrant
        FaceOrientIJK(18, CoordIJK(0, 2, 2), 3),  # jk quadrant
    ],
    [
        # face 14
        FaceOrientIJK(14, CoordIJK(0, 0, 0), 0),  # central face
        FaceOrientIJK(9, CoordIJK(2, 2, 0), 3),  # ij quadrant
        FaceOrientIJK(5, CoordIJK(2, 0, 2), 3),  # ki quadrant
        FaceOrientIJK(19, CoordIJK(0, 2, 2), 3),  # jk quadrant
    ],
    [
        # face 15
        FaceOrientIJK(15, CoordIJK(0, 0, 0), 0),  # central face
        FaceOrientIJK(16, CoordIJK(2, 0, 2), 1),  # ij quadrant
        FaceOrientIJK(19, CoordIJK(2, 2, 0), 5),  # ki quadrant
        FaceOrientIJK(10, CoordIJK(0, 2, 2), 3),  # jk quadrant
    ],
    [
        # face 16
        FaceOrientIJK(16, CoordIJK(0, 0, 0), 0),  # central face
        FaceOrientIJK(17, CoordIJK(2, 0, 2), 1),  # ij quadrant
        FaceOrientIJK(15, CoordIJK(2, 2, 0), 5),  # ki quadrant
        FaceOrientIJK(11, CoordIJK(0, 2, 2), 3),  # jk quadrant
    ],
    [
        # face 17
        FaceOrientIJK(17, CoordIJK(0, 0, 0), 0),  # central face
        FaceOrientIJK(18, CoordIJK(2, 0, 2), 1),  # ij quadrant
        FaceOrientIJK(16, CoordIJK(2, 2, 0), 5),  # ki quadrant
        FaceOrientIJK(12, CoordIJK(0, 2, 2), 3),  # jk quadrant
    ],
    [
        # face 18
        FaceOrientIJK(18, CoordIJK(0, 0, 0), 0),  # central face
        FaceOrientIJK(19, CoordIJK(2, 0, 2), 1),  # ij quadrant
        FaceOrientIJK(17, CoordIJK(2, 2, 0), 5),  # ki quadrant
        FaceOrientIJK(13, CoordIJK(0, 2, 2), 3),  # jk quadrant
    ],
    [
        # face 19
        FaceOrientIJK(19, CoordIJK(0, 0, 0), 0),  # central face
        FaceOrientIJK(15, CoordIJK(2, 0, 2), 1),  # ij quadrant
        FaceOrientIJK(18, CoordIJK(2, 2, 0), 5),  # ki quadrant
        FaceOrientIJK(14, CoordIJK(0, 2, 2), 3),  # jk quadrant
    ],
]

# Adjusts a FaceIJK address in place so that the resulting cell address is
# relative to the correct icosahedral face.
# @param fijk The FaceIJK address of the cell.
# @param res The H3 resolution of the cell.
# @param pentLeading4 Whether or not the cell is a pentagon with a leading
#        digit 4.
# @param substrate Whether or not the cell is in a substrate grid.
# @return 0 if on original face (no overage); 1 if on face edge (only occurs
#         on substrate grids); 2 if overage on new face interior
def _adjustOverageClassII(fijk, res, pentLeading4, substrate):
    overage = OVERAGE_NO_OVERAGE

    ijk = fijk.coord

    # get the maximum dimension value; scale if a substrate grid
    maxDim = maxDimByCIIres[res]
    if substrate:
        maxDim *= 3

    # check for overage
    if substrate and ijk.i + ijk.j + ijk.k == maxDim:  # on edge
        overage = OVERAGE_FACE_EDGE
    elif ijk.i + ijk.j + ijk.k > maxDim:  # overage
        overage = OVERAGE_NEW_FACE

        fijkOrient = FaceOrientIJK()
        if ijk.k > 0:
            if ijk.j > 0:  # jk "quadrant"
                fijkOrient = copy.deepcopy(faceNeighbors[fijk.face][JK])
            else:  # ik "quadrant"
                fijkOrient = copy.deepcopy(faceNeighbors[fijk.face][KI])

                # adjust for the pentagonal missing sequence
                if pentLeading4:
                    # translate origin to center of pentagon
                    origin = CoordIJK(i=maxDim)
                    tmp = CoordIJK()
                    _ijkSub(ijk, origin, tmp)
                    # rotate to adjust for the missing sequence
                    _ijkRotate60cw(tmp)
                    # translate the origin back to the center of the triangle
                    _ijkAdd(tmp, origin, ijk)
        else:  # ij "quadrant"
            fijkOrient = copy.deepcopy(faceNeighbors[fijk.face][IJ])

        fijk.face = fijkOrient.face

        # rotate and translate for adjacent face
        for i in range(fijkOrient.ccwRot60):
            _ijkRotate60ccw(ijk)

        transVec = fijkOrient.translate
        unitScale = unitScaleByCIIres[res]
        if substrate:
            unitScale *= 3
        _ijkScale(transVec, unitScale)
        _ijkAdd(ijk, transVec, ijk)
        _ijkNormalize(ijk)

        # overage points on pentagon boundaries can end up on edges
        if substrate and ijk.i + ijk.j + ijk.k == maxDim:  # on edge
            overage = OVERAGE_FACE_EDGE

    return overage


# Adjusts a FaceIJK address for a pentagon vertex in a substrate grid in
# place so that the resulting cell address is relative to the correct
# icosahedral face.
# @param fijk The FaceIJK address of the cell.
# @param res The H3 resolution of the cell.
def _adjustPentVertOverage(fijk, res):
    pentLeading4 = False
    overage = OVERAGE_NEW_FACE
    while overage == OVERAGE_NEW_FACE:
        overage = _adjustOverageClassII(fijk, res, pentLeading4, 1)
    return overage


# h3Index -----------------------------------------------------

# The number of bits in an H3 index.
H3_NUM_BITS = 64

# All 1s (0xffffffffffffffff), ANDed to obtain positive values
H3_MASK = (1 << H3_NUM_BITS) - 1

# The bit offset of the max resolution digit in an H3 index.
H3_MAX_OFFSET = 63

# The bit offset of the mode in an H3 index.
H3_MODE_OFFSET = 59

# The bit offset of the base cell in an H3 index.
H3_BC_OFFSET = 45

# The bit offset of the resolution in an H3 index.
H3_RES_OFFSET = 52

# The bit offset of the reserved bits in an H3 index.
H3_RESERVED_OFFSET = 56

# The number of bits in a single H3 resolution digit.
H3_PER_DIGIT_OFFSET = 3

# 1 in the highest bit, 0's everywhere else.
H3_HIGH_BIT_MASK = 1 << H3_MAX_OFFSET

# 0 in the highest bit, 1's everywhere else.
H3_HIGH_BIT_MASK_NEGATIVE = H3_MASK & (~H3_HIGH_BIT_MASK)

# 1's in the 4 mode bits, 0's everywhere else.
H3_MODE_MASK = 0xF << H3_MODE_OFFSET

# 0's in the 4 mode bits, 1's everywhere else.
H3_MODE_MASK_NEGATIVE = H3_MASK & (~H3_MODE_MASK)

# 1's in the 7 base cell bits, 0's everywhere else.
H3_BC_MASK = 0x7F << H3_BC_OFFSET

# 0's in the 7 base cell bits, 1's everywhere else.
H3_BC_MASK_NEGATIVE = H3_MASK & (~H3_BC_MASK)

# 1's in the 4 resolution bits, 0's everywhere else.
H3_RES_MASK = 0xF << H3_RES_OFFSET

# 0's in the 4 resolution bits, 1's everywhere else.
H3_RES_MASK_NEGATIVE = H3_MASK & (~H3_RES_MASK)

# 1's in the 3 reserved bits, 0's everywhere else.
H3_RESERVED_MASK = 7 << H3_RESERVED_OFFSET

# 0's in the 3 reserved bits, 1's everywhere else.
H3_RESERVED_MASK_NEGATIVE = H3_MASK & (~H3_RESERVED_MASK)

# 1's in the 3 bits of res 15 digit bits, 0's everywhere else.
H3_DIGIT_MASK = 7

# 0's in the 7 base cell bits, 1's everywhere else.
H3_DIGIT_MASK_NEGATIVE = H3_MASK & (~H3_DIGIT_MASK)

# H3 index with mode 0, res 0, base cell 0, and 7 for all index digits.
# Typically used to initialize the creation of an H3 cell index, which
# expects all direction digits to be 7 beyond the cell's resolution.
H3_INIT = 0x1FFFFFFFFFFF

# TODO: rename all public methods; avoid h3 (redundant with name of module)

# Gets the highest bit of the H3 index.
def h3_get_high_bit(h3):
    return (h3 & H3_HIGH_BIT_MASK) >> H3_MAX_OFFSET


# Sets the highest bit of the h3 to v.
def h3_set_high_bit(h3, v):
    return (h3 & H3_HIGH_BIT_MASK_NEGATIVE) | (v << H3_MAX_OFFSET)


# Gets the integer mode of h3.
def h3_get_mode(h3):
    return (h3 & H3_MODE_MASK) >> H3_MODE_OFFSET


# Sets the integer mode of h3 to v.
def h3_set_mode(h3, v):
    return (h3 & H3_MODE_MASK_NEGATIVE) | (v << H3_MODE_OFFSET)


# Gets the integer base cell of h3.
def h3_get_base_cell(h3):
    return (h3 & H3_BC_MASK) >> H3_BC_OFFSET


# Sets the integer base cell of h3 to bc.
def h3_set_base_cell(h3, bc):
    return (h3 & H3_BC_MASK_NEGATIVE) | (bc << H3_BC_OFFSET)


# Gets the integer resolution of h3.
def h3_get_resolution(h3):
    return (h3 & H3_RES_MASK) >> H3_RES_OFFSET


# Sets the integer resolution of h3.
def h3_set_resolution(h3, res):
    return (h3 & H3_RES_MASK_NEGATIVE) | (res < H3_RES_OFFSET)


# Gets the resolution res integer digit (0-7) of h3.
def h3_get_index_digit(h3, res):
    return (h3 >> ((MAX_H3_RES - res) * H3_PER_DIGIT_OFFSET)) & H3_DIGIT_MASK


# Sets a value in the reserved space. Setting to non-zero may produce invalid
# indexes.
def h3_set_reserved_bits(h3, v):
    return (h3 & H3_RESERVED_MASK_NEGATIVE) | (v << H3_RESERVED_OFFSET)


# Gets a value in the reserved space. Should always be zero for valid indexes.
def h3_get_reserved_bits(h3):
    return (h3 & H3_RESERVED_MASK) >> H3_RESERVED_OFFSET


# Sets the resolution res digit of h3 to the integer digit (0-7)
def h3_set_index_digit(h3, res, digit):
    mask = (MAX_H3_RES - res) * H3_PER_DIGIT_OFFSET
    return (h3 & (H3_MASK & ~(H3_DIGIT_MASK << mask))) | (digit << mask)


# Converts a string representation of an H3 index into an H3 index.
def h3_string_to_h3(str):
    return int(str, 16)


# Converts an H3 index into a string representation.
# @param h The H3 index to convert.
# @param str The string representation of the H3 index.
# @param sz Size of the buffer `str`
def h3_to_string(h):
    return hex(h)[2:]  # return '{0:x}'.format(h)


# Returns whether or not an H3 index is a valid cell (hexagon or pentagon).
# @param h The H3 index to validate.
# @return 1 if the H3 index if valid, and 0 if it is not.
def h3_is_valid_cell(h):
    if h3_get_high_bit(h) != 0:
        return False

    if h3_get_mode(h) != H3_CELL_MODE:
        return False

    if h3_get_reserved_bits(h) != 0:
        return False

    baseCell = h3_get_base_cell(h)
    if baseCell < 0 or baseCell >= NUM_BASE_CELLS:
        # Base cells less than zero can not be represented in an index
        return False

    res = h3_get_resolution(h)
    if res < 0 or res > MAX_H3_RES:
        # Resolutions less than zero can not be represented in an index
        return False

    foundFirstNonZeroDigit = False
    for r in range(2, res + 1):
        digit = h3_get_index_digit(h, r)

        if not foundFirstNonZeroDigit and digit != DIRECTION_CENTER_DIGIT:
            foundFirstNonZeroDigit = True
            if _isBaseCellPentagon(baseCell) and digit == DIRECTION_K_AXES_DIGIT:
                return False

        if digit < DIRECTION_CENTER_DIGIT or digit >= DIRECTION_NUM_DIGITS:
            return False

    for r in range(res + 1, MAX_H3_RES + 1):
        digit = h3_get_index_digit(h, r)
        if digit != DIRECTION_INVALID_DIGIT:
            return False

    return True


# baseCells ---------------------------------------------------

# @struct BaseCellData
# @brief information on a single base cell
class BaseCellData:
    def __init__(self, face, coord_i, coord_j, coord_k, is_pentagon, offsets=[0, 0]):
        self.homeFijk = FaceIJK(face, coord_i, coord_j, coord_k)
        self.isPentagon = is_pentagon
        self.cwOffsetPen = offsets


INVALID_BASE_CELL = 127

# Maximum input for any component to face-to-base-cell lookup functions
MAX_FACE_COORD = 2

# Invalid number of rotations
INVALID_ROTATIONS = -1

# @brief Resolution 0 base cell data table.
# For each base cell, gives the "home" face and ijk+ coordinates on that face,
# whether or not the base cell is a pentagon. Additionally, if the base cell
# is a pentagon, the two cw offset rotation adjacent faces are given (-1
# indicates that no cw offset rotation faces exist for this base cell).
# TODO: avoid mutable objects in tables
baseCellData = [
    BaseCellData(1, 1, 0, 0, False),  # base cell 0
    BaseCellData(2, 1, 1, 0, False),  # base cell 1
    BaseCellData(1, 0, 0, 0, False),  # base cell 2
    BaseCellData(2, 1, 0, 0, False),  # base cell 3
    BaseCellData(0, 2, 0, 0, True, [-1, -1]),  # base cell 4
    BaseCellData(1, 1, 1, 0, False),  # base cell 5
    BaseCellData(1, 0, 0, 1, False),  # base cell 6
    BaseCellData(2, 0, 0, 0, False),  # base cell 7
    BaseCellData(0, 1, 0, 0, False),  # base cell 8
    BaseCellData(2, 0, 1, 0, False),  # base cell 9
    BaseCellData(1, 0, 1, 0, False),  # base cell 10
    BaseCellData(1, 0, 1, 1, False),  # base cell 11
    BaseCellData(3, 1, 0, 0, False),  # base cell 12
    BaseCellData(3, 1, 1, 0, False),  # base cell 13
    BaseCellData(11, 2, 0, 0, True, [2, 6]),  # base cell 14
    BaseCellData(4, 1, 0, 0, False),  # base cell 15
    BaseCellData(0, 0, 0, 0, False),  # base cell 16
    BaseCellData(6, 0, 1, 0, False),  # base cell 17
    BaseCellData(0, 0, 0, 1, False),  # base cell 18
    BaseCellData(2, 0, 1, 1, False),  # base cell 19
    BaseCellData(7, 0, 0, 1, False),  # base cell 20
    BaseCellData(2, 0, 0, 1, False),  # base cell 21
    BaseCellData(0, 1, 1, 0, False),  # base cell 22
    BaseCellData(6, 0, 0, 1, False),  # base cell 23
    BaseCellData(10, 2, 0, 0, True, [1, 5]),  # base cell 24
    BaseCellData(6, 0, 0, 0, False),  # base cell 25
    BaseCellData(3, 0, 0, 0, False),  # base cell 26
    BaseCellData(11, 1, 0, 0, False),  # base cell 27
    BaseCellData(4, 1, 1, 0, False),  # base cell 28
    BaseCellData(3, 0, 1, 0, False),  # base cell 29
    BaseCellData(0, 0, 1, 1, False),  # base cell 30
    BaseCellData(4, 0, 0, 0, False),  # base cell 31
    BaseCellData(5, 0, 1, 0, False),  # base cell 32
    BaseCellData(0, 0, 1, 0, False),  # base cell 33
    BaseCellData(7, 0, 1, 0, False),  # base cell 34
    BaseCellData(11, 1, 1, 0, False),  # base cell 35
    BaseCellData(7, 0, 0, 0, False),  # base cell 36
    BaseCellData(10, 1, 0, 0, False),  # base cell 37
    BaseCellData(12, 2, 0, 0, True, [3, 7]),  # base cell 38
    BaseCellData(6, 1, 0, 1, False),  # base cell 39
    BaseCellData(7, 1, 0, 1, False),  # base cell 40
    BaseCellData(4, 0, 0, 1, False),  # base cell 41
    BaseCellData(3, 0, 0, 1, False),  # base cell 42
    BaseCellData(3, 0, 1, 1, False),  # base cell 43
    BaseCellData(4, 0, 1, 0, False),  # base cell 44
    BaseCellData(6, 1, 0, 0, False),  # base cell 45
    BaseCellData(11, 0, 0, 0, False),  # base cell 46
    BaseCellData(8, 0, 0, 1, False),  # base cell 47
    BaseCellData(5, 0, 0, 1, False),  # base cell 48
    BaseCellData(14, 2, 0, 0, True, [0, 9]),  # base cell 49
    BaseCellData(5, 0, 0, 0, False),  # base cell 50
    BaseCellData(12, 1, 0, 0, False),  # base cell 51
    BaseCellData(10, 1, 1, 0, False),  # base cell 52
    BaseCellData(4, 0, 1, 1, False),  # base cell 53
    BaseCellData(12, 1, 1, 0, False),  # base cell 54
    BaseCellData(7, 1, 0, 0, False),  # base cell 55
    BaseCellData(11, 0, 1, 0, False),  # base cell 56
    BaseCellData(10, 0, 0, 0, False),  # base cell 57
    BaseCellData(13, 2, 0, 0, True, [4, 8]),  # base cell 58
    BaseCellData(10, 0, 0, 1, False),  # base cell 59
    BaseCellData(11, 0, 0, 1, False),  # base cell 60
    BaseCellData(9, 0, 1, 0, False),  # base cell 61
    BaseCellData(8, 0, 1, 0, False),  # base cell 62
    BaseCellData(6, 2, 0, 0, True, [11, 15]),  # base cell 63
    BaseCellData(8, 0, 0, 0, False),  # base cell 64
    BaseCellData(9, 0, 0, 1, False),  # base cell 65
    BaseCellData(14, 1, 0, 0, False),  # base cell 66
    BaseCellData(5, 1, 0, 1, False),  # base cell 67
    BaseCellData(16, 0, 1, 1, False),  # base cell 68
    BaseCellData(8, 1, 0, 1, False),  # base cell 69
    BaseCellData(5, 1, 0, 0, False),  # base cell 70
    BaseCellData(12, 0, 0, 0, False),  # base cell 71
    BaseCellData(7, 2, 0, 0, True, [12, 16]),  # base cell 72
    BaseCellData(12, 0, 1, 0, False),  # base cell 73
    BaseCellData(10, 0, 1, 0, False),  # base cell 74
    BaseCellData(9, 0, 0, 0, False),  # base cell 75
    BaseCellData(13, 1, 0, 0, False),  # base cell 76
    BaseCellData(16, 0, 0, 1, False),  # base cell 77
    BaseCellData(15, 0, 1, 1, False),  # base cell 78
    BaseCellData(15, 0, 1, 0, False),  # base cell 79
    BaseCellData(16, 0, 1, 0, False),  # base cell 80
    BaseCellData(14, 1, 1, 0, False),  # base cell 81
    BaseCellData(13, 1, 1, 0, False),  # base cell 82
    BaseCellData(5, 2, 0, 0, True, [10, 19]),  # base cell 83
    BaseCellData(8, 1, 0, 0, False),  # base cell 84
    BaseCellData(14, 0, 0, 0, False),  # base cell 85
    BaseCellData(9, 1, 0, 1, False),  # base cell 86
    BaseCellData(14, 0, 0, 1, False),  # base cell 87
    BaseCellData(17, 0, 0, 1, False),  # base cell 88
    BaseCellData(12, 0, 0, 1, False),  # base cell 89
    BaseCellData(16, 0, 0, 0, False),  # base cell 90
    BaseCellData(17, 0, 1, 1, False),  # base cell 91
    BaseCellData(15, 0, 0, 1, False),  # base cell 92
    BaseCellData(16, 1, 0, 1, False),  # base cell 93
    BaseCellData(9, 1, 0, 0, False),  # base cell 94
    BaseCellData(15, 0, 0, 0, False),  # base cell 95
    BaseCellData(13, 0, 0, 0, False),  # base cell 96
    BaseCellData(8, 2, 0, 0, True, [13, 17]),  # base cell 97
    BaseCellData(13, 0, 1, 0, False),  # base cell 98
    BaseCellData(17, 1, 0, 1, False),  # base cell 99
    BaseCellData(19, 0, 1, 0, False),  # base cell 100
    BaseCellData(14, 0, 1, 0, False),  # base cell 101
    BaseCellData(19, 0, 1, 1, False),  # base cell 102
    BaseCellData(17, 0, 1, 0, False),  # base cell 103
    BaseCellData(13, 0, 0, 1, False),  # base cell 104
    BaseCellData(17, 0, 0, 0, False),  # base cell 105
    BaseCellData(16, 1, 0, 0, False),  # base cell 106
    BaseCellData(9, 2, 0, 0, True, [14, 18]),  # base cell 107
    BaseCellData(15, 1, 0, 1, False),  # base cell 108
    BaseCellData(15, 1, 0, 0, False),  # base cell 109
    BaseCellData(18, 0, 1, 1, False),  # base cell 110
    BaseCellData(18, 0, 0, 1, False),  # base cell 111
    BaseCellData(19, 0, 0, 1, False),  # base cell 112
    BaseCellData(17, 1, 0, 0, False),  # base cell 113
    BaseCellData(19, 0, 0, 0, False),  # base cell 114
    BaseCellData(18, 0, 1, 0, False),  # base cell 115
    BaseCellData(18, 1, 0, 1, False),  # base cell 116
    BaseCellData(19, 2, 0, 0, True, [-1, -1]),  # base cell 117
    BaseCellData(19, 1, 0, 0, False),  # base cell 118
    BaseCellData(18, 0, 0, 0, False),  # base cell 119
    BaseCellData(19, 1, 0, 1, False),  # base cell 120
    BaseCellData(18, 1, 0, 0, False),  # base cell 121
]

# @brief Return whether or not the indicated base cell is a pentagon.
def _isBaseCellPentagon(baseCell):
    if baseCell < 0 or baseCell >= NUM_BASE_CELLS:
        # Base cells less than zero can not be represented in an index
        return False
    return baseCellData[baseCell].isPentagon


def isResolutionClassIII(res):
    return (res % 2) == 1


# vec2d -------------------------------------------------
# @struct Vec2d
# @brief 2D floating-point vector
class Vec2d:
    def __init__(self, x, y):
        self.x = x
        self.y = y


# latlng ------------------------------------------------

# epsilon of ~0.1mm in degrees
EPSILON_DEG = 0.000000001
# epsilon of ~0.1mm in radians
EPSILON_RAD = EPSILON_DEG * M_PI_180


class LatLng:
    def __init__(self, lat, lng):
        self.lat = lat
        self.lng = lng


class LatLngDeg:
    def __init__(self, latlng):
        self.lat = latlng.lat * M_180_PI
        self.lng = latlng.lng * M_180_PI

    def rad(self):
        return LatLng(self.lat * M_PI_180, self.lng * M_PI_180)


# Normalizes radians to a value between 0.0 and two PI.
# @param rads The input radians value.
# @return The normalized radians value.
def _posAngleRads(rads):
    tmp = rads + M_2PI if rads < 0.0 else rads
    if rads >= M_2PI:
        tmp -= M_2PI
    return tmp


# constrainLng makes sure longitudes are in the proper bounds
#  @param lng The origin lng value
# @return The corrected lng value
def constrainLng(lng):
    while lng > M_PI:
        lng = lng - (2 * M_PI)

    while lng < -M_PI:
        lng = lng + (2 * M_PI)

    return lng


# Computes the point on the sphere a specified azimuth and distance from
# another point.
# @param p1 The first spherical coordinates.
# @param az The desired azimuth from p1.
# @param distance The desired distance from p1, must be non-negative.
# @return p2 The spherical coordinates at the desired azimuth and distance from
# p1.
def _geoAzDistanceRads(p1, az, distance):
    if distance < EPSILON:
        return p1

    sinlat = 0.0
    sinlng = 0.0
    coslng = 0.0
    lat = 0.0
    lng = 0, 0

    az = _posAngleRads(az)

    # check for due north/south azimuth
    if az < EPSILON or abs(az - M_PI) < EPSILON:
        if az < EPSILON:  # due north
            lat = p1.lat + distance
        else:  # due south
            lat = p1.lat - distance

        if abs(lat - M_PI_2) < EPSILON:  # north pole
            lat = M_PI_2
            lng = 0.0
        elif abs(lat + M_PI_2) < EPSILON:  # south pole
            lat = -M_PI_2
            lng = 0.0
        else:
            lng = constrainLng(p1.lng)
    else:  # not due north or south
        sinlat = math.sin(p1.lat) * math.cos(distance) + math.cos(p1.lat) * math.sin(
            distance
        ) * math.cos(az)
        if sinlat > 1.0:
            sinlat = 1.0
        if sinlat < -1.0:
            sinlat = -1.0
        lat = math.asin(sinlat)
        if abs(lat - M_PI_2) < EPSILON:  # north pole
            lat = M_PI_2
            lng = 0.0
        elif abs(lat + M_PI_2) < EPSILON:  # south pole
            lat = -M_PI_2
            lng = 0.0
        else:
            sinlng = math.sin(az) * math.sin(distance) / math.cos(lat)
            coslng = (
                (math.cos(distance) - math.sin(p1.lat) * math.sin(lat))
                / math.cos(p1.lat)
                / math.cos(lat)
            )

            if sinlng > 1.0:
                sinlng = 1.0
            if sinlng < -1.0:
                sinlng = -1.0
            if coslng > 1.0:
                coslng = 1.0
            if coslng < -1.0:
                coslng = -1.0
            lng = constrainLng(p1.lng + math.atan2(sinlng, coslng))

    return LatLng(lat, lng)


# Convert an H3Index to the FaceIJK address on a specified icosahedral face.
# @param h The H3Index
# @param (mutable) fijk The FaceIJK address, initialized with the desired face
# and normalized base cell coordinates.
# @return Returns boolean that indicates the possibility of overage
def _h3ToFaceIjkWithInitializedFijk(h, fijk):
    res = h3_get_resolution(h)

    # center base cell hierarchy is entirely on this face
    possibleOverage = True
    if not _isBaseCellPentagon(h3_get_base_cell(h)) and (
        res == 0 or (fijk.coord.i == 0 and fijk.coord.j == 0 and fijk.coord.k == 0)
    ):
        possibleOverage = False

    for r in range(1, res + 1):
        if isResolutionClassIII(r):
            # Class III == rotate ccw
            _downAp7(fijk.coord)
        else:
            # Class II == rotate cw
            _downAp7r(fijk.coord)

        _neighbor(fijk.coord, h3_get_index_digit(h, r))

    return possibleOverage


# Convert an H3Index to a FaceIJK address.
# @param h The H3Index.
# @returns The corresponding FaceIJK address or None for invalid
def _h3ToFaceIjk(h):
    baseCell = h3_get_base_cell(h)
    if baseCell < 0 or baseCell >= NUM_BASE_CELLS:  #
        # Base cells less than zero can not be represented in an index
        return None

    # adjust for the pentagonal missing sequence; all of sub-sequence 5 needs
    # to be adjusted (and some of sub-sequence 4 below)
    if _isBaseCellPentagon(baseCell) and _h3LeadingNonZeroDigit(h) == 5:
        h = _h3Rotate60cw(h)

    # start with the "home" face and ijk+ coordinates for the base cell of c
    fijk = copy.deepcopy(baseCellData[baseCell].homeFijk)
    if not _h3ToFaceIjkWithInitializedFijk(h, fijk):
        return fijk  # no overage is possible; h lies on this face

    # if we're here we have the potential for an "overage"; i.e., it is
    # possible that c lies on an adjacent face
    origIJK = copy.copy(fijk.coord)

    # if we're in Class III, drop into the next finer Class II grid
    res = h3_get_resolution(h)
    if isResolutionClassIII(res):
        # Class III
        _downAp7r(fijk.coord)
        res += 1

    # adjust for overage if needed
    # a pentagon base cell with a leading 4 digit requires special handling
    pentLeading4 = _isBaseCellPentagon(baseCell) and _h3LeadingNonZeroDigit(h) == 4
    if _adjustOverageClassII(fijk, res, pentLeading4, 0) != OVERAGE_NO_OVERAGE:
        # if the base cell is a pentagon we have the potential for secondary
        # overages
        if _isBaseCellPentagon(baseCell):
            while _adjustOverageClassII(fijk, res, 0, 0) != OVERAGE_NO_OVERAGE:
                pass

        if res != h3_get_resolution(h):
            _upAp7r(fijk.coord)
    elif res != h3_get_resolution(h):
        fijk.coord = origIJK

    return fijk


# Determines the center point in spherical coordinates of a cell given by
# a FaceIJK address at a specified resolution.
# @param h The FaceIJK address of the cell.
# @param res The H3 resolution of the cell.
# @return g The spherical coordinates of the cell center point.
def _faceIjkToGeo(h, res):
    v = _ijkToHex2d(h.coord)
    return _hex2dToGeo(v, h.face, res, 0)


# Find the center point in 2D cartesian coordinates of a hex.
# @param h The ijk coordinates of the hex.
# @retur v The 2D cartesian coordinates of the hex center point.
def _ijkToHex2d(h):
    i = h.i - h.k
    j = h.j - h.k
    return Vec2d(i - 0.5 * j, j * M_SQRT3_2)


# @brief icosahedron face centers in lat/lng radians
# TODO: avoid mutable objects in tables
faceCenterGeo = [
    LatLng(0.803582649718989942, 1.248397419617396099),  # face  0
    LatLng(1.307747883455638156, 2.536945009877921159),  # face  1
    LatLng(1.054751253523952054, -1.347517358900396623),  # face  2
    LatLng(0.600191595538186799, -0.450603909469755746),  # face  3
    LatLng(0.491715428198773866, 0.401988202911306943),  # face  4
    LatLng(0.172745327415618701, 1.678146885280433686),  # face  5
    LatLng(0.605929321571350690, 2.953923329812411617),  # face  6
    LatLng(0.427370518328979641, -1.888876200336285401),  # face  7
    LatLng(-0.079066118549212831, -0.733429513380867741),  # face  8
    LatLng(-0.230961644455383637, 0.506495587332349035),  # face  9
    LatLng(0.079066118549212831, 2.408163140208925497),  # face 10
    LatLng(0.230961644455383637, -2.635097066257444203),  # face 11
    LatLng(-0.172745327415618701, -1.463445768309359553),  # face 12
    LatLng(-0.605929321571350690, -0.187669323777381622),  # face 13
    LatLng(-0.427370518328979641, 1.252716453253507838),  # face 14
    LatLng(-0.600191595538186799, 2.690988744120037492),  # face 15
    LatLng(-0.491715428198773866, -2.739604450678486295),  # face 16
    LatLng(-0.803582649718989942, -1.893195233972397139),  # face 17
    LatLng(-1.307747883455638156, -0.604647643711872080),  # face 18
    LatLng(-1.054751253523952054, 1.794075294689396615),  # face 19
]

# @brief icosahedron face ijk axes as azimuth in radians from face center to
# vertex 0/1/2 respectively
faceAxesAzRadsCII = [
    [5.619958268523939882, 3.525563166130744542, 1.431168063737548730],  # face  0
    [5.760339081714187279, 3.665943979320991689, 1.571548876927796127],  # face  1
    [0.780213654393430055, 4.969003859179821079, 2.874608756786625655],  # face  2
    [0.430469363979999913, 4.619259568766391033, 2.524864466373195467],  # face  3
    [6.130269123335111400, 4.035874020941915804, 1.941478918548720291],  # face  4
    [2.692877706530642877, 0.598482604137447119, 4.787272808923838195],  # face  5
    [2.982963003477243874, 0.888567901084048369, 5.077358105870439581],  # face  6
    [3.532912002790141181, 1.438516900396945656, 5.627307105183336758],  # face  7
    [3.494305004259568154, 1.399909901866372864, 5.588700106652763840],  # face  8
    [3.003214169499538391, 0.908819067106342928, 5.097609271892733906],  # face  9
    [5.930472956509811562, 3.836077854116615875, 1.741682751723420374],  # face 10
    [0.138378484090254847, 4.327168688876645809, 2.232773586483450311],  # face 11
    [0.448714947059150361, 4.637505151845541521, 2.543110049452346120],  # face 12
    [0.158629650112549365, 4.347419854898940135, 2.253024752505744869],  # face 13
    [5.891865957979238535, 3.797470855586042958, 1.703075753192847583],  # face 14
    [2.711123289609793325, 0.616728187216597771, 4.805518392002988683],  # face 15
    [3.294508837434268316, 1.200113735041072948, 5.388903939827463911],  # face 16
    [3.804819692245439833, 1.710424589852244509, 5.899214794638635174],  # face 17
    [3.664438879055192436, 1.570043776661997111, 5.758833981448388027],  # face 18
    [2.361378999196363184, 0.266983896803167583, 4.455774101589558636],  # face 19
]

# Calculates the magnitude of a 2D cartesian vector.
# @param v The 2D cartesian vector.
# @return The magnitude of the vector.
def _v2dMag(v):
    return math.sqrt(v.x * v.x + v.y * v.y)


# Determines the center point in spherical coordinates of a cell given by 2D
# hex coordinates on a particular icosahedral face.
# @param v Vec2d The 2D hex coordinates of the cell.
# @param face The icosahedral face upon which the 2D hex coordinate system is
#             centered.
# @param res The H3 resolution of the cell.
# @param substrate Indicates whether or not this grid is actually a substrate
#        grid relative to the specified resolution.
# @return g LatLng The spherical coordinates of the cell center point.
def _hex2dToGeo(v, face, res, substrate):
    # calculate (r, theta) in hex2d
    r = _v2dMag(v)

    if r < EPSILON:
        return copy.copy(faceCenterGeo[face])

    theta = math.atan2(v.y, v.x)

    # scale for current resolution length u
    for _ in range(res):
        r /= M_SQRT7

    # scale accordingly if this is a substrate grid
    if substrate:
        r /= 3.0
        if isResolutionClassIII(res):
            r /= M_SQRT7

    r *= RES0_U_GNOMONIC

    # perform inverse gnomonic scaling of r
    r = math.atan(r)

    # adjust theta for Class III
    # if a substrate grid, then it's already been adjusted for Class III
    if not substrate and isResolutionClassIII(res):
        theta = _posAngleRads(theta + M_AP7_ROT_RADS)

    # find theta as an azimuth
    theta = _posAngleRads(faceAxesAzRadsCII[face][0] - theta)

    # now find the point at (r,theta) from the face center
    return _geoAzDistanceRads(copy.copy(faceCenterGeo[face]), theta, r)


def h3_cell_to_latlng(h3):
    return LatLngDeg(_faceIjkToGeo(_h3ToFaceIjk(h3), h3_get_resolution(h3)))
