local codepoints = {
    [0x0020] = {    0,  100,    7,   28 }, --  
    [0x0021] = {    7,  100,    8,   28 }, -- !
    [0x0022] = {   15,  100,    9,   28 }, -- "
    [0x0023] = {   24,  100,   13,   28 }, -- #
    [0x0024] = {   37,  100,   13,   28 }, -- $
    [0x0025] = {   50,  100,   21,   28 }, -- %
    [0x0026] = {   71,  100,   16,   28 }, -- &
    [0x0027] = {   87,  100,    5,   28 }, -- '
    [0x0028] = {   92,  100,    8,   28 }, -- (
    [0x0029] = {  100,  100,    8,   28 }, -- )
    [0x002a] = {  108,  100,    9,   28 }, -- *
    [0x002b] = {  117,  100,   14,   28 }, -- +
    [0x002c] = {  131,  100,    7,   28 }, -- ,
    [0x002d] = {  138,  100,    8,   28 }, -- -
    [0x002e] = {  146,  100,    7,   28 }, -- .
    [0x002f] = {  153,  100,    7,   28 }, -- /
    [0x0030] = {  160,  100,   13,   28 }, -- 0
    [0x0031] = {  173,  100,   13,   28 }, -- 1
    [0x0032] = {  186,  100,   13,   28 }, -- 2
    [0x0033] = {  199,  100,   13,   28 }, -- 3
    [0x0034] = {  212,  100,   13,   28 }, -- 4
    [0x0035] = {  225,  100,   13,   28 }, -- 5
    [0x0036] = {  238,  100,   13,   28 }, -- 6
    [0x0037] = {  251,  100,   13,   28 }, -- 7
    [0x0038] = {  264,  100,   13,   28 }, -- 8
    [0x0039] = {  277,  100,   13,   28 }, -- 9
    [0x003a] = {  290,  100,    7,   28 }, -- :
    [0x003b] = {  297,  100,    7,   28 }, -- ;
    [0x003c] = {  304,  100,   14,   28 }, -- <
    [0x003d] = {  318,  100,   14,   28 }, -- =
    [0x003e] = {  332,  100,   14,   28 }, -- >
    [0x003f] = {  346,  100,   13,   28 }, -- ?
    [0x0040] = {  359,  100,   24,   28 }, -- @
    [0x0041] = {  383,  100,   15,   28 }, -- A
    [0x0042] = {  398,  100,   16,   28 }, -- B
    [0x0043] = {  414,  100,   17,   28 }, -- C
    [0x0044] = {  431,  100,   17,   28 }, -- D
    [0x0045] = {  448,  100,   16,   28 }, -- E
    [0x0046] = {  464,  100,   15,   28 }, -- F
    [0x0047] = {  479,  100,   19,   28 }, -- G
    [0x0048] = {    0,   72,   17,   28 }, -- H
    [0x0049] = {   17,   72,    6,   28 }, -- I
    [0x004a] = {   23,   72,   12,   28 }, -- J
    [0x004b] = {   35,   72,   16,   28 }, -- K
    [0x004c] = {   51,   72,   13,   28 }, -- L
    [0x004d] = {   64,   72,   19,   28 }, -- M
    [0x004e] = {   83,   72,   17,   28 }, -- N
    [0x004f] = {  100,   72,   19,   28 }, -- O
    [0x0050] = {  119,   72,   16,   28 }, -- P
    [0x0051] = {  135,   72,   19,   28 }, -- Q
    [0x0052] = {  154,   72,   17,   28 }, -- R
    [0x0053] = {  171,   72,   16,   28 }, -- S
    [0x0054] = {  187,   72,   14,   28 }, -- T
    [0x0055] = {  201,   72,   17,   28 }, -- U
    [0x0056] = {  218,   72,   15,   28 }, -- V
    [0x0057] = {  233,   72,   23,   28 }, -- W
    [0x0058] = {  256,   72,   15,   28 }, -- X
    [0x0059] = {  271,   72,   16,   28 }, -- Y
    [0x005a] = {  287,   72,   15,   28 }, -- Z
    [0x005b] = {  302,   72,    7,   28 }, -- [
    [0x005c] = {  309,   72,    7,   28 }, -- \
    [0x005d] = {  316,   72,    7,   28 }, -- ]
    [0x005e] = {  323,   72,   12,   28 }, -- ^
    [0x005f] = {  335,   72,   13,   28 }, -- _
    [0x0060] = {  348,   72,    8,   28 }, -- `
    [0x0061] = {  356,   72,   13,   28 }, -- a
    [0x0062] = {  369,   72,   14,   28 }, -- b
    [0x0063] = {  383,   72,   12,   28 }, -- c
    [0x0064] = {  395,   72,   14,   28 }, -- d
    [0x0065] = {  409,   72,   13,   28 }, -- e
    [0x0066] = {  422,   72,    7,   28 }, -- f
    [0x0067] = {  429,   72,   14,   28 }, -- g
    [0x0068] = {  443,   72,   14,   28 }, -- h
    [0x0069] = {  457,   72,    5,   28 }, -- i
    [0x006a] = {  462,   72,    6,   28 }, -- j
    [0x006b] = {  468,   72,   12,   28 }, -- k
    [0x006c] = {  480,   72,    6,   28 }, -- l
    [0x006d] = {  486,   72,   20,   28 }, -- m
    [0x006e] = {    0,   44,   14,   28 }, -- n
    [0x006f] = {   14,   44,   13,   28 }, -- o
    [0x0070] = {   27,   44,   14,   28 }, -- p
    [0x0071] = {   41,   44,   14,   28 }, -- q
    [0x0072] = {   55,   44,    8,   28 }, -- r
    [0x0073] = {   63,   44,   12,   28 }, -- s
    [0x0074] = {   75,   44,    7,   28 }, -- t
    [0x0075] = {   82,   44,   14,   28 }, -- u
    [0x0076] = {   96,   44,   11,   28 }, -- v
    [0x0077] = {  107,   44,   17,   28 }, -- w
    [0x0078] = {  124,   44,   11,   28 }, -- x
    [0x0079] = {  135,   44,   12,   28 }, -- y
    [0x007a] = {  147,   44,   12,   28 }, -- z
    [0x007b] = {  159,   44,    8,   28 }, -- {
    [0x007c] = {  167,   44,    6,   28 }, -- |
    [0x007d] = {  173,   44,    8,   28 }, -- }
    [0x007e] = {  181,   44,   14,   28 }, -- ~
}
gge_gfx_font_define(`Arial24`, `font_arial24.png`, 28, codepoints)

material `Arial24` {
    shader = `Font`,
    diffuseMap = `font_arial24.png`,
    alphaRejectThreshold = 0.5,
}

material `Arial24Alpha` {
    shader = `Font`,
    diffuseMap = `font_arial24.png`,
    sceneBlend = "ALPHA";
}
