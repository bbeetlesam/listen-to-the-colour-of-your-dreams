local Camera = require("src.core.camera")
local Player = require("src.core.player")
local const = require("src.helpers.const")
local utils = require("src.helpers.utils")

---@class Beginning : Act
local act = {}

function act:load()
    Player:setPlayer(-16, 0, true, "diagonal")
    Camera:setPosition(-16, 0)
end

function act:update(dt)
    Player:update(dt)

    local px, py = Player:getPosition()
    Camera:setPosition(px, py - 32*3)
end

function act:draw()
    Camera:attach()
        utils.drawStairs(0, 0, 45)
        utils.lines({-32*5,0, 0,0})
        Player:draw()
    Camera:detach()
end

return act