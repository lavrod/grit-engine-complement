-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
local function grey(x) return vector3(x,x,x) end
local std_gloss = 0.7
local std_spec = 0.05
local std_spec2 = 0.05

carcols = {
-- please if you define colors put them in the accurate tone, and add a comment about it
    --silver
    ice_silver= { grey(.09), 0.1, std_gloss, std_spec  },
    cream_white= { vector3(.4,.38,.34), 0.1, 0.35, 0.01 },
    -- grey
    bianco_grey = { grey(0.2), 0.1, std_gloss, std_spec2},
    marrone_grey = { grey(0.1), 0.1, std_gloss, std_spec},
    carbon_gray = { grey(0.04), 0.1, std_gloss, std_spec},
    -- blacks
    midnight_black = { grey(0.015), 0.1, std_gloss, std_spec},
    -- reds
    velvet_red = { vector3(0.13,0.036,0.028), 0.15, std_gloss, std_spec},
    cold_red = { vector3(0.1,0.025,0.021), 0.2, std_gloss, std_spec},
    rosso_red = { vector3(0.19,0.026,0.011), 0.2, std_gloss, std_spec},
    -- orange 
    arancio_orange = { vector3(0.8,.17,0.03), 0.1, std_gloss, std_spec},
    -- yellow
    giallo_yellow = { vector3(0.45,0.3,0.04), 0.0, std_gloss, std_spec},
    -- green 
    ithaca_green = { vector3(0.18,0.6,0.0), 0.2, 0.7, 0.5},
    -- blue
    crystal_blue = { vector3(0.051, 0.072,0.12), 0.1, std_gloss, std_spec},
    caelum_blue = { vector3(0.06,0.083,0.13), 0.1, std_gloss, std_spec},
    fontus_blue = { vector3(0.045,0.045, 0.14), 0.15, std_gloss, std_spec2},


    white = { {1,1,1} },
    bright_grey = { {0.75,0.75,0.75} },
    grey = { {.5,.5,.5} },
    dark_grey = { {.25,.25,.25} },
    black = { {.01,.01,.01} },
    gold = { {1,.8,.4}, 0, 0.9, 0.9 },

    metallic_silver = { {.5,.5,.5}, 1, .75, .75 },
    metallic_gold = { {1,.8,.4}, 1, 0.9, 0.9 },
    metallic_black = { {.01,.01,.01}, 1, .2, .2 },

    brightest_red = { {1,0,0} },
    brightest_green = { {0,1,0} },
    brightest_blue = { {0,0,1} },
    brightest_cyan = { {0,1,1} },
    brightest_pink = { {1,0,1} },
    brightest_yellow = { {1,1,0} },
    brightest_orange = { {1,.5,0} },

    bright_red = { {0.75,0,0} },
    bright_green = { {0,0.75,0} },
    bright_blue = { {0,0,0.75} },
    bright_cyan = { {0,0.75,0.75} },
    bright_pink = { {0.75,0,0.75} },
    bright_yellow = { {0.75,0.75,0} },
    bright_orange = { {0.75,0.325,0} },

    red = { {.5,0,0} },
    green = { {0,.5,0} },
    blue = { {0,0,.5} },
    cyan = { {0,0.5,0.5} },
    pink = { {0.5,0,0.5} },
    yellow = { {0.5,0.5,0} },
    orange = { {0.5,0.25,0} },

    dark_red = { {.25,0,0} },
    dark_green = { {0,.25,0} },
    dark_blue = { {0,0,.25} },
    dark_cyan = { {0,0.25,0.25} },
    dark_pink = { {0.25,0,0.25} },
    dark_yellow = { {0.25,0.25,0} },
    dark_orange = { {0.25,0.125,0} },

    darkest_red = { {.1,0,0} },
    darkest_green = { {0,.1,0} },
    darkest_blue = { {0,0,.1} },
    darkest_cyan = { {0,0.1,0.1} },
    darkest_pink = { {0.1,0,0.1} },
    darkest_yellow = { {0.1,0.1,0} },
    darkest_orange = { {0.1,0.05,0} },

    brightest_metallic_red = { {1,0,0}, 1, 0.9, 0.9 },
    brightest_metallic_green = { {0,1,0}, 1, 0.9, 0.9 },
    brightest_metallic_blue = { {0,0,1}, 1, 0.9, 0.9 },
    brightest_metallic_cyan = { {0,1,1}, 1, 0.9, 0.9 },
    brightest_metallic_pink = { {1,0,1}, 1, 0.9, 0.9 },
    brightest_metallic_yellow = { {1,1,0}, 1, 0.9, 0.9 },
    brightest_metallic_orange = { {1,.5,0}, 1, 0.9, 0.9 },

    bright_metallic_red = { {0.75,0,0}, 1, 0.9, 0.9 },
    bright_metallic_green = { {0,0.75,0}, 1, 0.9, 0.9 },
    bright_metallic_blue = { {0,0,0.75}, 1, 0.9, 0.9 },
    bright_metallic_cyan = { {0,0.75,0.75}, 1, 0.9, 0.9 },
    bright_metallic_pink = { {0.75,0,0.75}, 1, 0.9, 0.9 },
    bright_metallic_yellow = { {0.75,0.75,0}, 1, 0.9, 0.9 },
    bright_metallic_orange = { {0.75,0.325,0}, 1, 0.9, 0.9 },

    metallic_red = { {.5,0,0}, 1, 0.9, 0.9 },
    metallic_green = { {0,.5,0}, 1, 0.9, 0.9 },
    metallic_blue = { {0,0,.5}, 1, 0.9, 0.9 },
    metallic_cyan = { {0,0.5,0.5}, 1, 0.9, 0.9 },
    metallic_pink = { {0.5,0,0.5}, 1, 0.9, 0.9 },
    metallic_yellow = { {0.5,0.5,0}, 1, 0.9, 0.9 },
    metallic_orange = { {0.5,0.25,0}, 1, 0.9, 0.9 },

    dark_metallic_red = { {.25,0,0}, 1, 0.9, 0.9 },
    dark_metallic_green = { {0,.25,0}, 1, 0.9, 0.9 },
    dark_metallic_blue = { {0,0,.25}, 1, 0.9, 0.9 },
    dark_metallic_cyan = { {0,0.25,0.25}, 1, 0.9, 0.9 },
    dark_metallic_pink = { {0.25,0,0.25}, 1, 0.9, 0.9 },
    dark_metallic_yellow = { {0.25,0.25,0}, 1, 0.9, 0.9 },
    dark_metallic_orange = { {0.25,0.125,0}, 1, 0.9, 0.9 },

    darkest_metallic_red = { {.1,0,0}, 1, 0.9, 0.9 },
    darkest_metallic_green = { {0,.1,0}, 1, 0.9, 0.9 },
    darkest_metallic_blue = { {0,0,.1}, 1, 0.9, 0.9 },
    darkest_metallic_cyan = { {0,0.1,0.1}, 1, 0.9, 0.9 },
    darkest_metallic_pink = { {0.1,0,0.1}, 1, 0.9, 0.9 },
    darkest_metallic_yellow = { {0.1,0.1,0}, 1, 0.9, 0.9 },
    darkest_metallic_orange = { {0.1,0.05,0}, 1, 0.9, 0.9 },

}

carcol_groups = {
    REDS = { "brightest_red", "dark_metallic_red", "brightest_metallic_red", "darkest_metallic_red", "bright_red", "metallic_red", "darkest_red", "bright_metallic_red", "dark_red", "red" },
    GREENS = { "brightest_green", "dark_metallic_green", "brightest_metallic_green", "darkest_metallic_green", "bright_green", "metallic_green", "darkest_green", "bright_metallic_green", "dark_green", "green" },
    BLUES = { "brightest_blue", "dark_metallic_blue", "brightest_metallic_blue", "darkest_metallic_blue", "bright_blue", "metallic_blue", "darkest_blue", "bright_metallic_blue", "dark_blue", "blue" },
    CYANS = { "brightest_cyan", "dark_metallic_cyan", "brightest_metallic_cyan", "darkest_metallic_cyan", "bright_cyan", "metallic_cyan", "darkest_cyan", "bright_metallic_cyan", "dark_cyan", "cyan" },
    PINKS = { "brightest_pink", "dark_metallic_pink", "brightest_metallic_pink", "darkest_metallic_pink", "bright_pink", "metallic_pink", "darkest_pink", "bright_metallic_pink", "dark_pink", "pink" },
    YELLOWS = { "brightest_yellow", "dark_metallic_yellow", "brightest_metallic_yellow", "darkest_metallic_yellow", "bright_yellow", "metallic_yellow", "darkest_yellow", "bright_metallic_yellow", "dark_yellow", "yellow" },
    ORANGES = { "brightest_orange", "dark_metallic_orange", "brightest_metallic_orange", "darkest_metallic_orange", "bright_orange", "metallic_orange", "darkest_orange", "bright_metallic_orange", "dark_orange", "orange" },
    COLOURLESS = { "white", "bright_grey", "grey", "dark_grey", "black", "metallic_silver", "metallic_black" },


    RED_METALLICS = { "dark_metallic_red", "brightest_metallic_red", "darkest_metallic_red", "metallic_red", "bright_metallic_red" },
    GREEN_METALLICS = { "dark_metallic_green", "brightest_metallic_green", "darkest_metallic_green", "bright_green", "metallic_green", "bright_metallic_green", },
    BLUE_NONMETALLICS = { "dark_blue", "brightest_blue", "darkest_blue", "blue", "bright_blue" },
    CYAN_NONMETALLICS = { "dark_cyan", "brightest_cyan", "darkest_cyan",  "cyan", "bright_cyan", },
    PINK_NONMETALLICS = { "dark_pink", "brightest_pink", "darkest_pink",  "pink", "bright_pink", },
    YELLOW_NONMETALLICS = { "dark_yellow", "brightest_yellow", "darkest_yellow", "yellow", "bright_yellow", },
    ORANGE_NONMETALLICS = { "dark_orange", "brightest_orange", "darkest_orange", "orange", "bright_orange", },
    COLOURLESS_NONMETALLICS = { "white", "bright_grey", "grey", "dark_grey", "black", },

    RED_METALLICS = { "dark_metallic_red", "brightest_metallic_red", "darkest_metallic_red", "metallic_red", "bright_metallic_red" },
    GREEN_METALLICS = { "dark_metallic_green", "brightest_metallic_green", "darkest_metallic_green", "metallic_green", "bright_metallic_green", },
    BLUE_METALLICS = { "dark_metallic_blue", "brightest_metallic_blue", "darkest_metallic_blue", "metallic_blue", "bright_metallic_blue" },
    CYAN_METALLICS = { "dark_metallic_cyan", "brightest_metallic_cyan", "darkest_metallic_cyan",  "metallic_cyan", "bright_metallic_cyan", },
    PINK_METALLICS = { "dark_metallic_pink", "brightest_metallic_pink", "darkest_metallic_pink",  "metallic_pink", "bright_metallic_pink", },
    YELLOW_METALLICS = { "dark_metallic_yellow", "brightest_metallic_yellow", "darkest_metallic_yellow", "metallic_yellow", "bright_metallic_yellow", },
    ORANGE_METALLICS = { "dark_metallic_orange", "brightest_metallic_orange", "darkest_metallic_orange", "metallic_orange", "bright_metallic_orange", },
    COLOURLESS_METALLICS = { "metallic_silver", "metallic_black" },

    METALLICS = { "dark_metallic_green", "bright_metallic_cyan", "darkest_metallic_yellow", "dark_metallic_orange", "darkest_metallic_orange", "metallic_black", "dark_metallic_blue", "brightest_metallic_blue", "darkest_metallic_blue", "metallic_orange", "metallic_cyan", "bright_metallic_red", "metallic_silver", "darkest_metallic_cyan", "metallic_blue", "metallic_green", "brightest_metallic_yellow", "dark_metallic_red", "metallic_yellow", "darkest_metallic_green", "bright_metallic_green", "bright_metallic_pink", "metallic_gold", "dark_metallic_pink", "darkest_metallic_pink", "brightest_metallic_pink", "darkest_metallic_red", "dark_metallic_yellow", "brightest_metallic_red", "bright_metallic_blue", "dark_metallic_cyan", "metallic_pink", "metallic_red", "bright_metallic_orange", "bright_metallic_yellow", "brightest_metallic_orange", "brightest_metallic_cyan", "brightest_metallic_green", },
    NONMETALLICS = { "dark_red", "bright_green", "cyan", "brightest_blue", "brightest_yellow", "bright_pink", "orange", "black", "yellow", "white", "dark_cyan", "brightest_pink", "darkest_yellow", "gold", "brightest_red", "dark_green", "bright_yellow", "bright_orange", "grey", "pink", "bright_blue", "bright_grey", "brightest_orange", "brightest_green", "red", "darkest_blue", "bright_red", "darkest_cyan", "dark_orange", "dark_blue", "blue", "darkest_orange", "dark_yellow", "bright_cyan", "darkest_red", "darkest_pink", "dark_grey", "dark_pink", "green", "darkest_green", "brightest_cyan" },
    
    BRIGHTEST_METALLICS = { "brightest_metallic_cyan", "brightest_metallic_red", "brightest_metallic_green", "brightest_metallic_pink", "brightest_metallic_blue", "brightest_metallic_orange", "brightest_metallic_yellow", },
    BRIGHT_METALLICS = { "metallic_gold", "bright_metallic_cyan", "bright_metallic_red", "bright_metallic_green", "bright_metallic_pink", "bright_metallic_blue", "bright_metallic_orange", "bright_metallic_yellow", },
    MIDRANGE_METALLICS = { "metallic_silver", "metallic_cyan", "metallic_red", "metallic_green", "metallic_pink", "metallic_blue", "metallic_orange", "metallic_yellow", },
    DARK_METALLICS = { "dark_metallic_cyan", "dark_metallic_red", "dark_metallic_green", "dark_metallic_pink", "dark_metallic_blue", "dark_metallic_orange", "dark_metallic_yellow", },
    DARKEST_METALLICS = { "metallic_black", "darkest_metallic_cyan", "darkest_metallic_red", "darkest_metallic_green", "darkest_metallic_pink", "darkest_metallic_blue", "darkest_metallic_orange", "darkest_metallic_yellow", },

    DARKESTS = { "black", "darkest_metallic_yellow", "darkest_metallic_orange", "darkest_yellow", "darkest_metallic_blue", "darkest_metallic_cyan", "darkest_blue", "darkest_cyan", "darkest_metallic_green", "darkest_metallic_pink", "darkest_metallic_red", "darkest_orange", "darkest_red", "darkest_pink", "darkest_green" },
    DARKS = { "dark_metallic_yellow", "dark_metallic_orange", "dark_yellow", "dark_metallic_blue", "dark_metallic_cyan", "dark_blue", "dark_cyan", "dark_metallic_green", "dark_metallic_pink", "dark_metallic_red", "dark_orange", "dark_red", "dark_pink", "dark_green" },
    MIDRANGES = { "cyan", "orange", "black", "yellow", "white", "metallic_black", "gold", "metallic_orange", "grey", "pink", "metallic_cyan", "light_grey", "metallic_silver", "metallic_blue", "metallic_green", "red", "metallic_yellow", "metallic_gold", "metallic_pink", "metallic_red", "blue", "green", },
    BRIGHTS = { "bright_grey", "bright_metallic_yellow", "bright_metallic_orange", "bright_yellow", "bright_metallic_blue", "bright_metallic_cyan", "bright_blue", "bright_cyan", "bright_metallic_green", "bright_metallic_pink", "bright_metallic_red", "bright_orange", "bright_red", "bright_pink", "bright_green" },
    BRIGHTESTS = { "white", "brightest_metallic_yellow", "bright_metallic_orange", "bright_yellow", "bright_metallic_blue", "bright_metallic_cyan", "bright_blue", "bright_cyan", "bright_metallic_green", "bright_metallic_pink", "bright_metallic_red", "bright_orange", "bright_red", "bright_pink", "bright_green" },
}
