local Camera = require("src.core.camera")
local Canvas = require("src.canvas")
local Player = require("src.core.player")
local const = require("src.helpers.const")
local utils  = require("src.helpers.utils")

local mainCanvas = {}

function mainCanvas:fitToScreenCanvas()
    local canvasW, canvasH = self.canvas:getSize("main")
    local windowW, windowH = love.graphics.getDimensions()

    self.scale = math.min(windowW / canvasW, windowH / canvasH)

    self.offsetX = (windowW / self.scale - canvasW) / 2
    self.offsetY = (windowH / self.scale - canvasH) / 2

    self.canvas:scale("main", self.scale, self.scale)
    self.canvas:translate("main", self.offsetX, self.offsetY)
end

function mainCanvas:load()
    self.canvas = Canvas:new()
    self.canvas:addNew("main", const.WIDTH, const.HEIGHT, {})

    self:fitToScreenCanvas()

    Player:load(-15, -15, true)
    Camera:load(0, 0, const.WIDTH, const.HEIGHT, 1)
end

function mainCanvas:update(dt)
    Player:update(dt)

    local px, py = Player:getPosition()
    Camera:setPosition(px, py - 100)

    print(Player:getPosition())
end

function mainCanvas:draw()
    self.canvas:drawTo("main", function ()
        love.graphics.clear(const.BROKEN_WHITE)

        Camera:attach()
            utils.drawStairs(0, 0, 20)
            utils.lines({-200,0, 0,0})
            Player:draw()
            love.graphics.setColor(const.BLACK)
            love.graphics.points(0,0)
            love.graphics.setColor(1, 1, 1)
        Camera:detach()
    end)

    self.canvas:drawAll({"main"})
end

function mainCanvas:resize(_, _)
    self:fitToScreenCanvas()
end

-- for external uses
function mainCanvas:getMainCanvas()
    return self.canvas
end

return mainCanvas