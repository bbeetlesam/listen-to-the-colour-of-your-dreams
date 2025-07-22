local utils = require("src.helpers.utils")

local const = {
    -- core constants
    WIDTH = 1280, -- main canvas's width
    HEIGHT = 720, -- main canvas's height
    LINE_WIDTH = 4,
    TILE_SIZE = 32,

    -- colors
    BROKEN_WHITE = utils.rgb(248, 247, 243, 255),
    BLACK = utils.rgb(0, 0, 0, 255),
}

return const