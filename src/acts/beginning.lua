local Camera = require("src.core.camera")
local Player = require("src.core.player")
local const = require("src.helpers.const")
local utils  = require("src.helpers.utils")

---@class Beginning : Act
local act = {}

function act:load()
    Player:load(-15, -15, true)
    Camera:load(0, 0, const.WIDTH, const.HEIGHT, 1)
end

function act:update(dt)
    Player:update(dt)

    local px, py = Player:getPosition()
    Camera:setPosition(px, py - 100)
end

function act:draw()
    love.graphics.clear(const.BROKEN_WHITE)

    Camera:attach()
        utils.drawStairs(0, 0, 20)
        utils.lines({-200,0, 0,0})
        Player:draw()
        love.graphics.setColor(const.BLACK)
        love.graphics.points(0,0)
        love.graphics.setColor(1, 1, 1)
    Camera:detach()
end

return act