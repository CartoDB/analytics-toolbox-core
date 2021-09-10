
__version__ = '1.0.0'

# H3 constants
H3_INIT = 35184372088831
H3_CELL_MODE = 1
H3_MAX_FACE_COORD = 2
H3_PER_DIGIT_OFFSET = 3
H3_DIGIT_MASK = 7
H3_NUM_DIGITS = 7
H3_INVALID_DIGIT = 7
H3_MAX_RES = 15
H3_NUM_BITS = 64
H3_MAX_OFFSET = 63
H3_MODE_OFFSET = 59
H3_RESERVED_OFFSET = 56
H3_BC_OFFSET = 45
H3_RES_OFFSET = 52
H3_NUM_BASE_CELLS = 122
H3_HIGH_BIT_MASK = 1 << H3_MAX_OFFSET
H3_MODE_MASK = 15 << H3_MODE_OFFSET
H3_MODE_MASK_NEGATIVE = ~H3_MODE_MASK
H3_RESERVED_MASK = 7 << H3_RESERVED_OFFSET
H3_BC_MASK = 127 << H3_BC_OFFSET
H3_BC_MASK_NEGATIVE = ~H3_BC_MASK
H3_RES_MASK = 15 << H3_RES_OFFSET
H3_RES_MASK_NEGATIVE = ~H3_RES_MASK
H3_CENTER_DIGIT = 0
H3_K_AXES_DIGIT = 1
H3_BASE_CELL_PENTA = [
    0,  # base cell 0
    0,  # base cell 1
    0,  # base cell 2
    0,  # base cell 3
    1,  # base cell 4
    0,  # base cell 5
    0,  # base cell 6
    0,  # base cell 7
    0,  # base cell 8
    0,  # base cell 9
    0,  # base cell 10
    0,  # base cell 11
    0,  # base cell 12
    0,  # base cell 13
    1,  # base cell 14
    0,  # base cell 15
    0,  # base cell 16
    0,  # base cell 17
    0,  # base cell 18
    0,  # base cell 19
    0,  # base cell 20
    0,  # base cell 21
    0,  # base cell 22
    0,  # base cell 23
    1,  # base cell 24
    0,  # base cell 25
    0,  # base cell 26
    0,  # base cell 27
    0,  # base cell 28
    0,  # base cell 29
    0,  # base cell 30
    0,  # base cell 31
    0,  # base cell 32
    0,  # base cell 33
    0,  # base cell 34
    0,  # base cell 35
    0,  # base cell 36
    0,  # base cell 37
    1,  # base cell 38
    0,  # base cell 39
    0,  # base cell 40
    0,  # base cell 41
    0,  # base cell 42
    0,  # base cell 43
    0,  # base cell 44
    0,  # base cell 45
    0,  # base cell 46
    0,  # base cell 47
    0,  # base cell 48
    1,  # base cell 49
    0,  # base cell 50
    0,  # base cell 51
    0,  # base cell 52
    0,  # base cell 53
    0,  # base cell 54
    0,  # base cell 55
    0,  # base cell 56
    0,  # base cell 57
    1,  # base cell 58
    0,  # base cell 59
    0,  # base cell 60
    0,  # base cell 61
    0,  # base cell 62
    1,  # base cell 63
    0,  # base cell 64
    0,  # base cell 65
    0,  # base cell 66
    0,  # base cell 67
    0,  # base cell 68
    0,  # base cell 69
    0,  # base cell 70
    0,  # base cell 71
    1,  # base cell 72
    0,  # base cell 73
    0,  # base cell 74
    0,  # base cell 75
    0,  # base cell 76
    0,  # base cell 77
    0,  # base cell 78
    0,  # base cell 79
    0,  # base cell 80
    0,  # base cell 81
    0,  # base cell 82
    1,  # base cell 83
    0,  # base cell 84
    0,  # base cell 85
    0,  # base cell 86
    0,  # base cell 87
    0,  # base cell 88
    0,  # base cell 89
    0,  # base cell 90
    0,  # base cell 91
    0,  # base cell 92
    0,  # base cell 93
    0,  # base cell 94
    0,  # base cell 95
    0,  # base cell 96
    1,  # base cell 97
    0,  # base cell 98
    0,  # base cell 99
    0,  # base cell 100
    0,  # base cell 101
    0,  # base cell 102
    0,  # base cell 103
    0,  # base cell 104
    0,  # base cell 105
    0,  # base cell 106
    1,  # base cell 107
    0,  # base cell 108
    0,  # base cell 109
    0,  # base cell 110
    0,  # base cell 111
    0,  # base cell 112
    0,  # base cell 113
    0,  # base cell 114
    0,  # base cell 115
    0,  # base cell 116
    1,  # base cell 117
    0,  # base cell 118
    0,  # base cell 119
    0,  # base cell 120
    0,  # base cell 121
]


H3_FACE_IJK_BASE_CELLS = [
    [# face 0
     [
         # i 0
         [[16, 0], [18, 0], [24, 0]],  # j 0
         [[33, 0], [30, 0], [32, 3]],  # j 1
         [[49, 1], [48, 3], [50, 3]]   # j 2
     ],
     [
         # i 1
         [[8, 0], [5, 5], [10, 5]],    # j 0
         [[22, 0], [16, 0], [18, 0]],  # j 1
         [[41, 1], [33, 0], [30, 0]]   # j 2
     ],
     [
         # i 2
         [[4, 0], [0, 5], [2, 5]],    # j 0
         [[15, 1], [8, 0], [5, 5]],   # j 1
         [[31, 1], [22, 0], [16, 0]]  # j 2
     ]],
    [# face 1
     [
         # i 0
         [[2, 0], [6, 0], [14, 0]],    # j 0
         [[10, 0], [11, 0], [17, 3]],  # j 1
         [[24, 1], [23, 3], [25, 3]]   # j 2
     ],
     [
         # i 1
         [[0, 0], [1, 5], [9, 5]],    # j 0
         [[5, 0], [2, 0], [6, 0]],    # j 1
         [[18, 1], [10, 0], [11, 0]]  # j 2
     ],
     [
         # i 2
         [[4, 1], [3, 5], [7, 5]],  # j 0
         [[8, 1], [0, 0], [1, 5]],  # j 1
         [[16, 1], [5, 0], [2, 0]]  # j 2
     ]],
    [# face 2
     [
         # i 0
         [[7, 0], [21, 0], [38, 0]],  # j 0
         [[9, 0], [19, 0], [34, 3]],  # j 1
         [[14, 1], [20, 3], [36, 3]]  # j 2
     ],
     [
         # i 1
         [[3, 0], [13, 5], [29, 5]],  # j 0
         [[1, 0], [7, 0], [21, 0]],   # j 1
         [[6, 1], [9, 0], [19, 0]]    # j 2
     ],
     [
         # i 2
         [[4, 2], [12, 5], [26, 5]],  # j 0
         [[0, 1], [3, 0], [13, 5]],   # j 1
         [[2, 1], [1, 0], [7, 0]]     # j 2
     ]],
    [# face 3
     [
         # i 0
         [[26, 0], [42, 0], [58, 0]],  # j 0
         [[29, 0], [43, 0], [62, 3]],  # j 1
         [[38, 1], [47, 3], [64, 3]]   # j 2
     ],
     [
         # i 1
         [[12, 0], [28, 5], [44, 5]],  # j 0
         [[13, 0], [26, 0], [42, 0]],  # j 1
         [[21, 1], [29, 0], [43, 0]]   # j 2
     ],
     [
         # i 2
         [[4, 3], [15, 5], [31, 5]],  # j 0
         [[3, 1], [12, 0], [28, 5]],  # j 1
         [[7, 1], [13, 0], [26, 0]]   # j 2
     ]],
    [# face 4
     [
         # i 0
         [[31, 0], [41, 0], [49, 0]],  # j 0
         [[44, 0], [53, 0], [61, 3]],  # j 1
         [[58, 1], [65, 3], [75, 3]]   # j 2
     ],
     [
         # i 1
         [[15, 0], [22, 5], [33, 5]],  # j 0
         [[28, 0], [31, 0], [41, 0]],  # j 1
         [[42, 1], [44, 0], [53, 0]]   # j 2
     ],
     [
         # i 2
         [[4, 4], [8, 5], [16, 5]],    # j 0
         [[12, 1], [15, 0], [22, 5]],  # j 1
         [[26, 1], [28, 0], [31, 0]]   # j 2
     ]],
    [# face 5
     [
         # i 0
         [[50, 0], [48, 0], [49, 3]],  # j 0
         [[32, 0], [30, 3], [33, 3]],  # j 1
         [[24, 3], [18, 3], [16, 3]]   # j 2
     ],
     [
         # i 1
         [[70, 0], [67, 0], [66, 3]],  # j 0
         [[52, 3], [50, 0], [48, 0]],  # j 1
         [[37, 3], [32, 0], [30, 3]]   # j 2
     ],
     [
         # i 2
         [[83, 0], [87, 3], [85, 3]],  # j 0
         [[74, 3], [70, 0], [67, 0]],  # j 1
         [[57, 1], [52, 3], [50, 0]]   # j 2
     ]],
    [# face 6
     [
         # i 0
         [[25, 0], [23, 0], [24, 3]],  # j 0
         [[17, 0], [11, 3], [10, 3]],  # j 1
         [[14, 3], [6, 3], [2, 3]]     # j 2
     ],
     [
         # i 1
         [[45, 0], [39, 0], [37, 3]],  # j 0
         [[35, 3], [25, 0], [23, 0]],  # j 1
         [[27, 3], [17, 0], [11, 3]]   # j 2
     ],
     [
         # i 2
         [[63, 0], [59, 3], [57, 3]],  # j 0
         [[56, 3], [45, 0], [39, 0]],  # j 1
         [[46, 3], [35, 3], [25, 0]]   # j 2
     ]],
    [# face 7
     [
         # i 0
         [[36, 0], [20, 0], [14, 3]],  # j 0
         [[34, 0], [19, 3], [9, 3]],   # j 1
         [[38, 3], [21, 3], [7, 3]]    # j 2
     ],
     [
         # i 1
         [[55, 0], [40, 0], [27, 3]],  # j 0
         [[54, 3], [36, 0], [20, 0]],  # j 1
         [[51, 3], [34, 0], [19, 3]]   # j 2
     ],
     [
         # i 2
         [[72, 0], [60, 3], [46, 3]],  # j 0
         [[73, 3], [55, 0], [40, 0]],  # j 1
         [[71, 3], [54, 3], [36, 0]]   # j 2
     ]],
    [# face 8
     [
         # i 0
         [[64, 0], [47, 0], [38, 3]],  # j 0
         [[62, 0], [43, 3], [29, 3]],  # j 1
         [[58, 3], [42, 3], [26, 3]]   # j 2
     ],
     [
         # i 1
         [[84, 0], [69, 0], [51, 3]],  # j 0
         [[82, 3], [64, 0], [47, 0]],  # j 1
         [[76, 3], [62, 0], [43, 3]]   # j 2
     ],
     [
         # i 2
         [[97, 0], [89, 3], [71, 3]],  # j 0
         [[98, 3], [84, 0], [69, 0]],  # j 1
         [[96, 3], [82, 3], [64, 0]]   # j 2
     ]],
    [# face 9
     [
         # i 0
         [[75, 0], [65, 0], [58, 3]],  # j 0
         [[61, 0], [53, 3], [44, 3]],  # j 1
         [[49, 3], [41, 3], [31, 3]]   # j 2
     ],
     [
         # i 1
         [[94, 0], [86, 0], [76, 3]],  # j 0
         [[81, 3], [75, 0], [65, 0]],  # j 1
         [[66, 3], [61, 0], [53, 3]]   # j 2
     ],
     [
         # i 2
         [[107, 0], [104, 3], [96, 3]],  # j 0
         [[101, 3], [94, 0], [86, 0]],   # j 1
         [[85, 3], [81, 3], [75, 0]]     # j 2
     ]],
    [# face 10
     [
         # i 0
         [[57, 0], [59, 0], [63, 3]],  # j 0
         [[74, 0], [78, 3], [79, 3]],  # j 1
         [[83, 3], [92, 3], [95, 3]]   # j 2
     ],
     [
         # i 1
         [[37, 0], [39, 3], [45, 3]],  # j 0
         [[52, 0], [57, 0], [59, 0]],  # j 1
         [[70, 3], [74, 0], [78, 3]]   # j 2
     ],
     [
         # i 2
         [[24, 0], [23, 3], [25, 3]],  # j 0
         [[32, 3], [37, 0], [39, 3]],  # j 1
         [[50, 3], [52, 0], [57, 0]]   # j 2
     ]],
    [# face 11
     [
         # i 0
         [[46, 0], [60, 0], [72, 3]],  # j 0
         [[56, 0], [68, 3], [80, 3]],  # j 1
         [[63, 3], [77, 3], [90, 3]]   # j 2
     ],
     [
         # i 1
         [[27, 0], [40, 3], [55, 3]],  # j 0
         [[35, 0], [46, 0], [60, 0]],  # j 1
         [[45, 3], [56, 0], [68, 3]]   # j 2
     ],
     [
         # i 2
         [[14, 0], [20, 3], [36, 3]],  # j 0
         [[17, 3], [27, 0], [40, 3]],  # j 1
         [[25, 3], [35, 0], [46, 0]]   # j 2
     ]],
    [# face 12
     [
         # i 0
         [[71, 0], [89, 0], [97, 3]],   # j 0
         [[73, 0], [91, 3], [103, 3]],  # j 1
         [[72, 3], [88, 3], [105, 3]]   # j 2
     ],
     [
         # i 1
         [[51, 0], [69, 3], [84, 3]],  # j 0
         [[54, 0], [71, 0], [89, 0]],  # j 1
         [[55, 3], [73, 0], [91, 3]]   # j 2
     ],
     [
         # i 2
         [[38, 0], [47, 3], [64, 3]],  # j 0
         [[34, 3], [51, 0], [69, 3]],  # j 1
         [[36, 3], [54, 0], [71, 0]]   # j 2
     ]],
    [# face 13
     [
         # i 0
         [[96, 0], [104, 0], [107, 3]],  # j 0
         [[98, 0], [110, 3], [115, 3]],  # j 1
         [[97, 3], [111, 3], [119, 3]]   # j 2
     ],
     [
         # i 1
         [[76, 0], [86, 3], [94, 3]],   # j 0
         [[82, 0], [96, 0], [104, 0]],  # j 1
         [[84, 3], [98, 0], [110, 3]]   # j 2
     ],
     [
         # i 2
         [[58, 0], [65, 3], [75, 3]],  # j 0
         [[62, 3], [76, 0], [86, 3]],  # j 1
         [[64, 3], [82, 0], [96, 0]]   # j 2
     ]],
    [# face 14
     [
         # i 0
         [[85, 0], [87, 0], [83, 3]],     # j 0
         [[101, 0], [102, 3], [100, 3]],  # j 1
         [[107, 3], [112, 3], [114, 3]]   # j 2
     ],
     [
         # i 1
         [[66, 0], [67, 3], [70, 3]],   # j 0
         [[81, 0], [85, 0], [87, 0]],   # j 1
         [[94, 3], [101, 0], [102, 3]]  # j 2
     ],
     [
         # i 2
         [[49, 0], [48, 3], [50, 3]],  # j 0
         [[61, 3], [66, 0], [67, 3]],  # j 1
         [[75, 3], [81, 0], [85, 0]]   # j 2
     ]],
    [# face 15
     [
         # i 0
         [[95, 0], [92, 0], [83, 0]],  # j 0
         [[79, 0], [78, 0], [74, 3]],  # j 1
         [[63, 1], [59, 3], [57, 3]]   # j 2
     ],
     [
         # i 1
         [[109, 0], [108, 0], [100, 5]],  # j 0
         [[93, 1], [95, 0], [92, 0]],     # j 1
         [[77, 1], [79, 0], [78, 0]]      # j 2
     ],
     [
         # i 2
         [[117, 4], [118, 5], [114, 5]],  # j 0
         [[106, 1], [109, 0], [108, 0]],  # j 1
         [[90, 1], [93, 1], [95, 0]]      # j 2
     ]],
    [# face 16
     [
         # i 0
         [[90, 0], [77, 0], [63, 0]],  # j 0
         [[80, 0], [68, 0], [56, 3]],  # j 1
         [[72, 1], [60, 3], [46, 3]]   # j 2
     ],
     [
         # i 1
         [[106, 0], [93, 0], [79, 5]],  # j 0
         [[99, 1], [90, 0], [77, 0]],   # j 1
         [[88, 1], [80, 0], [68, 0]]    # j 2
     ],
     [
         # i 2
         [[117, 3], [109, 5], [95, 5]],  # j 0
         [[113, 1], [106, 0], [93, 0]],  # j 1
         [[105, 1], [99, 1], [90, 0]]    # j 2
     ]],
    [# face 17
     [
         # i 0
         [[105, 0], [88, 0], [72, 0]],  # j 0
         [[103, 0], [91, 0], [73, 3]],  # j 1
         [[97, 1], [89, 3], [71, 3]]    # j 2
     ],
     [
         # i 1
         [[113, 0], [99, 0], [80, 5]],   # j 0
         [[116, 1], [105, 0], [88, 0]],  # j 1
         [[111, 1], [103, 0], [91, 0]]   # j 2
     ],
     [
         # i 2
         [[117, 2], [106, 5], [90, 5]],  # j 0
         [[121, 1], [113, 0], [99, 0]],  # j 1
         [[119, 1], [116, 1], [105, 0]]  # j 2
     ]],
    [# face 18
     [
         # i 0
         [[119, 0], [111, 0], [97, 0]],  # j 0
         [[115, 0], [110, 0], [98, 3]],  # j 1
         [[107, 1], [104, 3], [96, 3]]   # j 2
     ],
     [
         # i 1
         [[121, 0], [116, 0], [103, 5]],  # j 0
         [[120, 1], [119, 0], [111, 0]],  # j 1
         [[112, 1], [115, 0], [110, 0]]   # j 2
     ],
     [
         # i 2
         [[117, 1], [113, 5], [105, 5]],  # j 0
         [[118, 1], [121, 0], [116, 0]],  # j 1
         [[114, 1], [120, 1], [119, 0]]   # j 2
     ]],
    [# face 19
     [
         # i 0
         [[114, 0], [112, 0], [107, 0]],  # j 0
         [[100, 0], [102, 0], [101, 3]],  # j 1
         [[83, 1], [87, 3], [85, 3]]      # j 2
     ],
     [
         # i 1
         [[118, 0], [120, 0], [115, 5]],  # j 0
         [[108, 1], [114, 0], [112, 0]],  # j 1
         [[92, 1], [100, 0], [102, 0]]    # j 2
     ],
     [
         # i 2
         [[117, 0], [121, 5], [119, 5]],  # j 0
         [[109, 1], [118, 0], [120, 0]],  # j 1
         [[95, 1], [108, 1], [114, 0]]    # j 2
     ]]]


# H3 data structs
class CoordIJK:
    def __init__(self, i, j, k):
        self.i = i
        self.j = j
        self.k = k

class FaceIJK:
    def __init__(self, coord, face):
        self.coord = coord
        self.face = face

UNIT_VECS = [
    CoordIJK(0,0,0),
    CoordIJK(0,0,1),
    CoordIJK(0,1,0),
    CoordIJK(0,1,1),
    CoordIJK(1,0,0),
    CoordIJK(1,0,1),
    CoordIJK(1,1,0)
]

# H3 main functions

def h3_is_valid(h3_index):
    """
    Boolean for whether or not the format of a H3 index is valid, including
    checks for valid encoding of location.
    :param h3_index: H3 index (string)
    :return: True if the H3 is valid, False otherwise
    """
    h3_integer = string_to_h3(h3_index)

    if h3_integer == 0:
        return False

    if (int)((h3_integer & H3_HIGH_BIT_MASK) >> H3_MAX_OFFSET) != 0:
        return False
    
    if (int)((h3_integer & H3_MODE_MASK) >> H3_MODE_OFFSET) != H3_CELL_MODE:
        return False

    if (int)((h3_integer & H3_RESERVED_MASK) >> H3_RESERVED_OFFSET) != 0:
        return False

    base_cell = (h3_integer & H3_BC_MASK) >> H3_BC_OFFSET
    if base_cell < 0 or base_cell >= H3_NUM_BASE_CELLS:
        return False

    res = (int)((h3_integer & H3_RES_MASK) >> H3_RES_OFFSET)
    
    if res < 0 or res > H3_MAX_RES:
        # Resolutions less than zero can not be represented in an index
        return False

    found_first_non_zero_digit = False

    for i in range(1, res + 1):
        digit = (h3_integer >> ((H3_MAX_RES - (res)) * H3_PER_DIGIT_OFFSET)) & H3_DIGIT_MASK

        if not found_first_non_zero_digit and digit != H3_CENTER_DIGIT:
            found_first_non_zero_digit = True
            if H3_BASE_CELL_PENTA[base_cell] == 1 and digit == H3_K_AXES_DIGIT:
                return False
        
        if digit < H3_CENTER_DIGIT or digit >= H3_NUM_DIGITS:
            return False

    for r in range(res + 1, H3_MAX_RES + 1):
        digit = (h3_integer >> ((H3_MAX_RES - (r)) * H3_PER_DIGIT_OFFSET)) & H3_DIGIT_MASK
        if digit != H3_NUM_DIGITS:
            return False

    return True

def geo_to_h3(lat, long, resolution):
    """
    Return the cell containing the (lat, long) point
    for a given resolution.
    :param lat: latitude (float)
    :param long: longitude (float)
    :param resolution: H3 resolution level (int)
    :return: H3 index
    """
    # latLngToCell (h3Index.c)
    # _geoToFaceIjk (faceijk.c)
    # _geoToHex2d (faceijk.c)
    # _faceIjkToH3 (h3Index.c)

    return _out_scalar(_cy.geo_to_h3(lat, lng, resolution))

# Auxiliary functions

def is_resolution_class_III(res):
    return res % 2

def h3_set_mode(h3, v):
    return ((h3)&H3_MODE_MASK_NEGATIVE) or (v << H3_MODE_OFFSET)

def h3_set_resolution(h3, res):
    return ((h3)&H3_RES_MASK_NEGATIVE) or (res << H3_RES_OFFSET)

def h3_set_base_cell(h3, base_cell):
    return ((h3)&H3_BC_MASK_NEGATIVE) or (base_cell << H3_BC_OFFSET)

def h3_set_index_digit(h3, res, digit):
    return (((h3) & ~((H3_DIGIT_MASK << ((H3_MAX_RES - (res)) * H3_PER_DIGIT_OFFSET)))) or
            (((digit)) << ((H3_MAX_RES - (res)) * H3_PER_DIGIT_OFFSET)))

def face_ijk_to_base_cell(fijk):
    return H3_FACE_IJK_BASE_CELLS[fijk.face][fijk.coord.i][fijk.coord.j][fijk.coord.k]

def ijk_normalize(c):
    # remove any negative values
    coordijk = c
    if coordijk.i < 0:
        coordijk.j -= coordijk.i
        coordijk.k -= coordijk.i
        coordijk.i = 0

    if coordijk.j < 0:
        coordijk.i -= coordijk.j
        coordijk.k -= coordijk.j
        coordijk.j = 0

    if coordijk.k < 0:
        coordijk.i -= coordijk.k
        coordijk.j -= coordijk.k
        coordijk.k = 0

    # remove the min value if needed
    min = coordijk.i
    if coordijk.j < min:
        min = coordijk.j

    if coordijk.k < min:
        min = coordijk.k

    if min > 0:
        coordijk.i -= min
        coordijk.j -= min
        coordijk.k -= min
    
    return coordijk

def up_ap_7(ijk):
    #convert to CoordIJ
    i = ijk.i - ijk.k
    j = ijk.j - ijk.k

    ijk.i = (int)round((3 * i - j) / 7.0)
    ijk.j = (int)round((i + 2 * j) / 7.0)
    ijk.k = 0

    return ijk_normalize(ijk)

def up_ap_7_r(ijk):
    #convert to CoordIJ
    i = ijk.i - ijk.k
    j = ijk.j - ijk.k

    ijk.i = (int)round((2 * i + j) / 7.0)
    ijk.j = (int)round((3 + j - i) / 7.0)
    ijk.k = 0

    return ijk_normalize(ijk)

def down_ap_7(ijk):
    # res r unit vectors in res r+1
    i_vec = CoordIJK(3, 0, 1)
    j_vec = CoordIJK(1, 3, 0)
    k_vec = CoordIJK(0, 1, 3)

    i_vec = ijk_scale(i_vec, ijk.i)
    j_vec = ijk_scale(j_vec, ijk.j)
    k_vec = ijk_scale(k_vec, ijk.k)

    ijk = ijk_add(i_vec, j_vec)
    ijk = ijk_add(ijk, k_vec)

    return ijk_normalize(ijk)

def down_ap_7_r(ijk):
    # res r unit vectors in res r+1
    i_vec = CoordIJK(3, 1, 0)
    j_vec = CoordIJK(0, 3, 1)
    k_vec = CoordIJK(1, 0, 3)

    i_vec = ijk_scale(i_vec, ijk.i)
    j_vec = ijk_scale(j_vec, ijk.j)
    k_vec = ijk_scale(k_vec, ijk.k)

    ijk = ijk_add(i_vec, j_vec)
    ijk = ijk_add(ijk, k_vec)

    return ijk_normalize(ijk)

def ijk_scale(c, factor):
    coordijk = c
    coordijk.i *= factor
    coordijk.j *= factor
    coordijk.k *= factor

    return coordijk

def ijk_add(h1, h2):
    sum = CoordIJK()
    sum.i = h1.i + h2.i
    sum.j = h1.j + h2.j
    sum.k = h1.k + h2.k

    return sum

def ijk_sub(h1, h2):
    diff = CoordIJK()
    diff.i = h1.i - h2.i
    diff.j = h1.j - h2.j
    diff.k = h1.k - h2.k

    return diff

def ijk_matches(c1, c2):
    return (c1.i == c2.i and c1.j == c2.j and c1.k == c2.k)

def unit_ijk_to_digit(ijk):
    c = ijk
    c = ijk_normalize(c)

    digit = H3_INVALID_DIGIT
    for i in range(H3_NUM_DIGITS):
        if ijk_matches(c, UNIT_VECS[i]):
            digit = i
            break
        }
    }

    return digit

def face_ijk_to_h3(fijk, resolution):
    # initialize the index
    h = H3_INIT

    h = h3_set_mode(h, H3_CELL_MODE)
    h = h3_set_resolution(h, resolution)

    # check for res 0/base cell
    if resolution == 0:
        if fijk.coord.i > H3_MAX_FACE_COORD or fijk.coord.j > H3_MAX_FACE_COORD or fijk.coord.k > H3_MAX_FACE_COORD:
            # out of range input
            return None

        h = h3_set_base_cell(h, face_ijk_to_base_cell(fijk))
        return h
    
    
    # we need to find the correct base cell FaceIJK for this H3 index;
    # start with the passed in face and resolution res ijk coordinates
    # in that face's coordinate system
    fijk_bc = fijk

    # build the H3Index from finest res up
    # adjust r for the fact that the res 0 base cell offsets the indexing
    # digits
    ijk = fijk_bc.coord
    for r in reversed(range(resolution - 1)):
        last_ijk = ijk
        lastCenter = CoordIJK()
        if is_resolution_class_III(r + 1):
            #rotate ccw
            ijk = up_ap_7(ijk)
            last_center = ijk
            last_center = down_ap_7(last_center)
        else:
            #rotate cw
            up_ap_7_r(ijk)
            last_center = ijk
            last_center = down_ap_7_r(last_center)

        diff = ijk_sub(&lastIJK, &lastCenter, &diff)
        diff = ijk_normalize(diff)

        h = h3_set_index_digit(h, r + 1, unit_ijk_to_digit(diff))
    

    # fijk_bc should now hold the IJK of the base cell in the
    # coordinate system of the current face

    if fijk_bc.coord.i > H3_MAX_FACE_COORD or fijk_bc.coord.j > H3_MAX_FACE_COORD or
        fijk_bc.coord.k > H3_MAX_FACE_COORD:
        # out of range input
        return None


    # lookup the correct base cell
    base_cell = face_ijk_to_base_cell(fijk_bc)
    h = h3_set_base_cell(h, base_cell)

    # rotate if necessary to get canonical base cell orientation
    # for this base cell
#    int numRots = _faceIjkToBaseCellCCWrot60(&fijkBC);
#    if (_isBaseCellPentagon(baseCell)) {
#        // force rotation out of missing k-axes sub-sequence
#        if (_h3LeadingNonZeroDigit(h) == K_AXES_DIGIT) {
#            // check for a cw/ccw offset face; default is ccw
#            if (_baseCellIsCwOffset(baseCell, fijkBC.face)) {
#                h = _h3Rotate60cw(h);
#            } else {
#                h = _h3Rotate60ccw(h);
#            }
#        }
#
#        for (int i = 0; i < numRots; i++) h = _h3RotatePent60ccw(h);
#    } else {
#        for (int i = 0; i < numRots; i++) {
#            h = _h3Rotate60ccw(h);
#        }
#    }
#
#    return h;

def string_to_h3(h3_index):
    result = 0
    if type(h3_index) != str: 
        return result

    try: 
        result = int(h3_index, 16)
    except:
        result = 0

    return result

def encode_h3_int(h3_integer):
    short_h3_integer = shorten_h3_integer(h3_integer)
    encoded_short_h3 = encode_short_int(short_h3_integer)

    clean_encoded_short_h3 = clean_string(encoded_short_h3)
    if len(clean_encoded_short_h3) <= CODE_LENGTH:
        clean_encoded_short_h3 = str.rjust(clean_encoded_short_h3, CODE_LENGTH, PADDING_CHAR)

    return '@' + '-'.join(clean_encoded_short_h3[i:i + TUPLE_LENGTH]
                          for i in range(0, len(clean_encoded_short_h3), TUPLE_LENGTH))

def shorten_h3_integer(h3_integer):
    # Cuts off the 12 left-most bits that don't code location
    out = (h3_integer + BASE_CELL_SHIFT) % (2 ** 52)
    # Cuts off the rightmost bits corresponding to resolutions greater than the base resolution
    out = out >> (3 * (15 - BASE_RESOLUTION))
    return out

def encode_short_int(x):
    if x == 0:
        return ALPHABET[0]
    else:
        res = ''
        while x > 0:
            remainder = x % ALPHABET_LENGTH
            res = ALPHABET[remainder] + res
            x = x // ALPHABET_LENGTH
        return res

def clean_string(s):
    # Replacement should be in order
    for k, v in REPLACEMENT_MAP:
        if k in s:
            s = s.replace(k, v)
    return s


def strip_encoding(s):
    s = s.replace('@', '').replace('-', '').replace(PADDING_CHAR, '')
    return s

def dirty_string(s):
    # Replacement should be in (reversed) order
    for k, v in REPLACEMENT_MAP[::-1]:
        if v in s:
            s = s.replace(v, k)
    return s

def decode_string(s):
    val = 0
    for i in range(len(s)):
        val += (ALPHABET_LENGTH ** i) * ALPHABET.index(s[-1 - i])
    return val

def unshorten_h3_integer(short_h3_integer):
    unshifted_int = short_h3_integer << (3 * (15 - BASE_RESOLUTION))
    rebuilt_int = ((HEADER_INT + UNUSED_RESOLUTION_FILLER) - BASE_CELL_SHIFT) + unshifted_int

    return rebuilt_int

def int_to_h3_string(h3_integer):
    return str(hex(h3_integer)).lstrip("0x")


