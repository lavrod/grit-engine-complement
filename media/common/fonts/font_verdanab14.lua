local codepoints = {
    [0x0020] = {    0,  110,    5,   18 }, --  
    [0x0021] = {    5,  110,    6,   18 }, -- !
    [0x0022] = {   11,  110,    8,   18 }, -- "
    [0x0023] = {   19,  110,   12,   18 }, -- #
    [0x0024] = {   31,  110,   10,   18 }, -- $
    [0x0025] = {   41,  110,   18,   18 }, -- %
    [0x0026] = {   59,  110,   12,   18 }, -- &
    [0x0027] = {   71,  110,    5,   18 }, -- '
    [0x0028] = {   76,  110,    8,   18 }, -- (
    [0x0029] = {   84,  110,    8,   18 }, -- )
    [0x002a] = {   92,  110,   10,   18 }, -- *
    [0x002b] = {  102,  110,   12,   18 }, -- +
    [0x002c] = {  114,  110,    5,   18 }, -- ,
    [0x002d] = {  119,  110,    7,   18 }, -- -
    [0x002e] = {  126,  110,    5,   18 }, -- .
    [0x002f] = {  131,  110,   10,   18 }, -- /
    [0x0030] = {  141,  110,   10,   18 }, -- 0
    [0x0031] = {  151,  110,   10,   18 }, -- 1
    [0x0032] = {  161,  110,   10,   18 }, -- 2
    [0x0033] = {  171,  110,   10,   18 }, -- 3
    [0x0034] = {  181,  110,   10,   18 }, -- 4
    [0x0035] = {  191,  110,   10,   18 }, -- 5
    [0x0036] = {  201,  110,   10,   18 }, -- 6
    [0x0037] = {  211,  110,   10,   18 }, -- 7
    [0x0038] = {  221,  110,   10,   18 }, -- 8
    [0x0039] = {  231,  110,   10,   18 }, -- 9
    [0x003a] = {  241,  110,    6,   18 }, -- :
    [0x003b] = {  247,  110,    6,   18 }, -- ;
    [0x003c] = {    0,   92,   12,   18 }, -- <
    [0x003d] = {   12,   92,   12,   18 }, -- =
    [0x003e] = {   24,   92,   12,   18 }, -- >
    [0x003f] = {   36,   92,    9,   18 }, -- ?
    [0x0040] = {   45,   92,   14,   18 }, -- @
    [0x0041] = {   59,   92,   11,   18 }, -- A
    [0x0042] = {   70,   92,   11,   18 }, -- B
    [0x0043] = {   81,   92,   11,   18 }, -- C
    [0x0044] = {   92,   92,   11,   18 }, -- D
    [0x0045] = {  103,   92,   10,   18 }, -- E
    [0x0046] = {  113,   92,    9,   18 }, -- F
    [0x0047] = {  122,   92,   11,   18 }, -- G
    [0x0048] = {  133,   92,   11,   18 }, -- H
    [0x0049] = {  144,   92,    8,   18 }, -- I
    [0x004a] = {  152,   92,    8,   18 }, -- J
    [0x004b] = {  160,   92,   11,   18 }, -- K
    [0x004c] = {  171,   92,    9,   18 }, -- L
    [0x004d] = {  180,   92,   13,   18 }, -- M
    [0x004e] = {  193,   92,   11,   18 }, -- N
    [0x004f] = {  204,   92,   12,   18 }, -- O
    [0x0050] = {  216,   92,   10,   18 }, -- P
    [0x0051] = {  226,   92,   12,   18 }, -- Q
    [0x0052] = {  238,   92,   11,   18 }, -- R
    [0x0053] = {    0,   74,   10,   18 }, -- S
    [0x0054] = {   10,   74,   10,   18 }, -- T
    [0x0055] = {   20,   74,   11,   18 }, -- U
    [0x0056] = {   31,   74,   11,   18 }, -- V
    [0x0057] = {   42,   74,   16,   18 }, -- W
    [0x0058] = {   58,   74,   11,   18 }, -- X
    [0x0059] = {   69,   74,   10,   18 }, -- Y
    [0x005a] = {   79,   74,   10,   18 }, -- Z
    [0x005b] = {   89,   74,    8,   18 }, -- [
    [0x005c] = {   97,   74,   10,   18 }, -- \
    [0x005d] = {  107,   74,    8,   18 }, -- ]
    [0x005e] = {  115,   74,   12,   18 }, -- ^
    [0x005f] = {  127,   74,   10,   18 }, -- _
    [0x0060] = {  137,   74,   10,   18 }, -- `
    [0x0061] = {  147,   74,    9,   18 }, -- a
    [0x0062] = {  156,   74,   10,   18 }, -- b
    [0x0063] = {  166,   74,    8,   18 }, -- c
    [0x0064] = {  174,   74,   10,   18 }, -- d
    [0x0065] = {  184,   74,    9,   18 }, -- e
    [0x0066] = {  193,   74,    6,   18 }, -- f
    [0x0067] = {  199,   74,   10,   18 }, -- g
    [0x0068] = {  209,   74,   10,   18 }, -- h
    [0x0069] = {  219,   74,    4,   18 }, -- i
    [0x006a] = {  223,   74,    6,   18 }, -- j
    [0x006b] = {  229,   74,    9,   18 }, -- k
    [0x006c] = {  238,   74,    4,   18 }, -- l
    [0x006d] = {    0,   56,   14,   18 }, -- m
    [0x006e] = {   14,   56,   10,   18 }, -- n
    [0x006f] = {   24,   56,   10,   18 }, -- o
    [0x0070] = {   34,   56,   10,   18 }, -- p
    [0x0071] = {   44,   56,   10,   18 }, -- q
    [0x0072] = {   54,   56,    7,   18 }, -- r
    [0x0073] = {   61,   56,    8,   18 }, -- s
    [0x0074] = {   69,   56,    6,   18 }, -- t
    [0x0075] = {   75,   56,   10,   18 }, -- u
    [0x0076] = {   85,   56,    9,   18 }, -- v
    [0x0077] = {   94,   56,   14,   18 }, -- w
    [0x0078] = {  108,   56,    9,   18 }, -- x
    [0x0079] = {  117,   56,    9,   18 }, -- y
    [0x007a] = {  126,   56,    8,   18 }, -- z
    [0x007b] = {  134,   56,   10,   18 }, -- {
    [0x007c] = {  144,   56,    8,   18 }, -- |
    [0x007d] = {  152,   56,   10,   18 }, -- }
    [0x007e] = {  162,   56,   12,   18 }, -- ~
}
gfx_font_define(`VerdanaBold14`, `font_verdanab14.png`, 18, codepoints)

material `VerdanaBold14` {
    shader = `Font`,
    diffuseMap = `font_verdanab14.png`,
    alphaRejectThreshold = 0.5,
}

material `VerdanaBold14Alpha` {
    shader = `Font`,
    diffuseMap = `font_verdanab14.png`,
    sceneBlend = "ALPHA";
}
