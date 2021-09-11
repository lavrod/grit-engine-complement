local codepoints = {
    [0x0020] = {    0,  110,    2,   18 }, --  
    [0x0021] = {    2,  110,    4,   18 }, -- !
    [0x0022] = {    6,  110,    5,   18 }, -- "
    [0x0023] = {   11,  110,    9,   18 }, -- #
    [0x0024] = {   20,  110,    8,   18 }, -- $
    [0x0025] = {   28,  110,   10,   18 }, -- %
    [0x0026] = {   38,  110,    8,   18 }, -- &
    [0x0027] = {   46,  110,    3,   18 }, -- '
    [0x0028] = {   49,  110,    4,   18 }, -- (
    [0x0029] = {   53,  110,    4,   18 }, -- )
    [0x002a] = {   57,  110,    4,   18 }, -- *
    [0x002b] = {   61,  110,    7,   18 }, -- +
    [0x002c] = {   68,  110,    2,   18 }, -- ,
    [0x002d] = {   70,  110,    4,   18 }, -- -
    [0x002e] = {   74,  110,    3,   18 }, -- .
    [0x002f] = {   77,  110,    6,   18 }, -- /
    [0x0030] = {   83,  110,    8,   18 }, -- 0
    [0x0031] = {   91,  110,    5,   18 }, -- 1
    [0x0032] = {   96,  110,    7,   18 }, -- 2
    [0x0033] = {  103,  110,    7,   18 }, -- 3
    [0x0034] = {  110,  110,    7,   18 }, -- 4
    [0x0035] = {  117,  110,    8,   18 }, -- 5
    [0x0036] = {  125,  110,    8,   18 }, -- 6
    [0x0037] = {  133,  110,    5,   18 }, -- 7
    [0x0038] = {  138,  110,    7,   18 }, -- 8
    [0x0039] = {  145,  110,    8,   18 }, -- 9
    [0x003a] = {  153,  110,    3,   18 }, -- :
    [0x003b] = {  156,  110,    3,   18 }, -- ;
    [0x003c] = {  159,  110,    7,   18 }, -- <
    [0x003d] = {  166,  110,    7,   18 }, -- =
    [0x003e] = {  173,  110,    7,   18 }, -- >
    [0x003f] = {  180,  110,    7,   18 }, -- ?
    [0x0040] = {  187,  110,   11,   18 }, -- @
    [0x0041] = {  198,  110,    7,   18 }, -- A
    [0x0042] = {  205,  110,    8,   18 }, -- B
    [0x0043] = {  213,  110,    8,   18 }, -- C
    [0x0044] = {  221,  110,    8,   18 }, -- D
    [0x0045] = {  229,  110,    6,   18 }, -- E
    [0x0046] = {  235,  110,    6,   18 }, -- F
    [0x0047] = {  241,  110,    8,   18 }, -- G
    [0x0048] = {  249,  110,    8,   18 }, -- H
    [0x0049] = {  257,  110,    4,   18 }, -- I
    [0x004a] = {  261,  110,    5,   18 }, -- J
    [0x004b] = {  266,  110,    8,   18 }, -- K
    [0x004c] = {  274,  110,    5,   18 }, -- L
    [0x004d] = {  279,  110,   10,   18 }, -- M
    [0x004e] = {  289,  110,    8,   18 }, -- N
    [0x004f] = {  297,  110,    8,   18 }, -- O
    [0x0050] = {  305,  110,    7,   18 }, -- P
    [0x0051] = {  312,  110,    8,   18 }, -- Q
    [0x0052] = {  320,  110,    8,   18 }, -- R
    [0x0053] = {  328,  110,    7,   18 }, -- S
    [0x0054] = {  335,  110,    6,   18 }, -- T
    [0x0055] = {  341,  110,    8,   18 }, -- U
    [0x0056] = {  349,  110,    7,   18 }, -- V
    [0x0057] = {  356,  110,   11,   18 }, -- W
    [0x0058] = {  367,  110,    7,   18 }, -- X
    [0x0059] = {  374,  110,    7,   18 }, -- Y
    [0x005a] = {  381,  110,    6,   18 }, -- Z
    [0x005b] = {  387,  110,    4,   18 }, -- [
    [0x005c] = {  391,  110,    6,   18 }, -- \
    [0x005d] = {  397,  110,    4,   18 }, -- ]
    [0x005e] = {  401,  110,    7,   18 }, -- ^
    [0x005f] = {  408,  110,    8,   18 }, -- _
    [0x0060] = {  416,  110,    5,   18 }, -- `
    [0x0061] = {  421,  110,    7,   18 }, -- a
    [0x0062] = {  428,  110,    7,   18 }, -- b
    [0x0063] = {  435,  110,    7,   18 }, -- c
    [0x0064] = {  442,  110,    7,   18 }, -- d
    [0x0065] = {  449,  110,    7,   18 }, -- e
    [0x0066] = {  456,  110,    4,   18 }, -- f
    [0x0067] = {  460,  110,    7,   18 }, -- g
    [0x0068] = {  467,  110,    7,   18 }, -- h
    [0x0069] = {  474,  110,    4,   18 }, -- i
    [0x006a] = {  478,  110,    4,   18 }, -- j
    [0x006b] = {  482,  110,    7,   18 }, -- k
    [0x006c] = {  489,  110,    4,   18 }, -- l
    [0x006d] = {  493,  110,   10,   18 }, -- m
    [0x006e] = {  503,  110,    7,   18 }, -- n
    [0x006f] = {    0,   92,    7,   18 }, -- o
    [0x0070] = {    7,   92,    7,   18 }, -- p
    [0x0071] = {   14,   92,    7,   18 }, -- q
    [0x0072] = {   21,   92,    5,   18 }, -- r
    [0x0073] = {   26,   92,    7,   18 }, -- s
    [0x0074] = {   33,   92,    4,   18 }, -- t
    [0x0075] = {   37,   92,    7,   18 }, -- u
    [0x0076] = {   44,   92,    7,   18 }, -- v
    [0x0077] = {   51,   92,    9,   18 }, -- w
    [0x0078] = {   60,   92,    5,   18 }, -- x
    [0x0079] = {   65,   92,    6,   18 }, -- y
    [0x007a] = {   71,   92,    5,   18 }, -- z
    [0x007b] = {   76,   92,    5,   18 }, -- {
    [0x007c] = {   81,   92,    4,   18 }, -- |
    [0x007d] = {   85,   92,    5,   18 }, -- }
    [0x007e] = {   90,   92,    7,   18 }, -- ~
}
gge_gfx_font_define(`Impact14`, `font_impact14.png`, 18, codepoints)

material `Impact14` {
    shader = `Font`,
    diffuseMap = `font_impact14.png`,
    alphaRejectThreshold = 0.5,
}

material `Impact14Alpha` {
    shader = `Font`,
    diffuseMap = `font_impact14.png`,
    sceneBlend = "ALPHA";
}
