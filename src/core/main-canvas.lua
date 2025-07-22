local Canvas = require("src.canvas")
local const = require("src.helpers.const")
local acts = require("src.acts")

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

    acts:load("beginning")
end

function mainCanvas:update(dt)
    acts:update(dt)

    print(require("src.core.player"):getPosition())
end

function mainCanvas:draw()
    self.canvas:drawTo("main", function ()
        acts:draw()
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