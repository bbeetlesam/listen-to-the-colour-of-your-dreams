local Canvas = require("src.canvas")
local Player = require("src.core.player")
local Camera = require("src.core.camera")
local Acts = require("src.acts")
local const = require("src.helpers.const")
local states = require("src.states")

local mainCanvas = {}

function mainCanvas:fitToScreen()
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

    self:fitToScreen()

    Player:load()
    Camera:load(0, 0, const.WIDTH, const.HEIGHT, 1)

    Acts:load("going-home")
end

function mainCanvas:update(dt)
    Acts:update(dt)
    print(Player:getPosF())
end

function mainCanvas:draw()
    love.graphics.clear(states.lineColor)
    self.canvas:drawTo("main", function ()
        love.graphics.clear(states.bgColor)

        -- debug grid
        -- require("src.helpers.utils").drawGrid(32)

        Acts:draw()
        require("src.dialogues"):draw()
    end)

    self.canvas:drawAll({"main"})
end

function mainCanvas:resize(_, _)
    self:fitToScreen()
end

-- for external uses
function mainCanvas:getMainCanvas()
    return self.canvas
end

function mainCanvas:getMouseCanvasPosition()
    local mx, my = love.mouse.getPosition()
    local scaledX = (mx / self.scale) - self.offsetX
    local scaledY = (my / self.scale) - self.offsetY
    return scaledX, scaledY
end

return mainCanvas