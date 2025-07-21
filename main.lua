local const = require("src.const")
local Player = require("src.core.player")
local Camera = require("src.core.camera")
local utils  = require("src.utils")

local canvas
local scale, offsetX, offsetY = 1, 0, 0

local function stairs(x, y, depth, size, linewidth, direction)
    depth = depth or 1
    size = size or 10
    linewidth = linewidth or 1
    direction = direction or "right"

    local dir = direction == "right" and 1 or -1

    local points = {x, y}
    for i = 1, depth - 0 do
        -- add the corner point at the bottom of the vertical riser
        table.insert(points, x + (i - 1) * size * dir)
        table.insert(points, y + i * size)

        -- add the corner point at the end of the horizontal tread
        table.insert(points, x + i * size * dir)
        table.insert(points, y + i * size)
    end

    love.graphics.push("all")
    love.graphics.setLineWidth(linewidth)
    love.graphics.setColor(const.BLACK)
    love.graphics.line(points)
    love.graphics.pop()
end

local function calculateScale()
    if not canvas then return end
    local canvasW, canvasH = canvas:getDimensions()
    local windowW, windowH = love.graphics.getDimensions()

    scale = math.min(windowW / canvasW, windowH / canvasH)

    offsetX = (windowW / scale - canvasW) / 2
    offsetY = (windowH / scale - canvasH) / 2

    return canvasW*scale, canvasH*scale
end

function love.load()
    canvas = love.graphics.newCanvas(1280, 720)
    calculateScale()

    Player:load(-15, -15, true)
    Camera:load(0, 0)
end

function love.update(dt)
    Player:update(dt)

    Camera:setPosition(Player:getPosition())

    print(Player:getPosition())
end

function love.draw()
    love.graphics.setCanvas(canvas)
        love.graphics.clear(const.BROKEN_WHITE)

        Camera:attach()
            stairs(0, 0, 20, 30, 4, "right")
            utils.lines({-200,0, 0,0})
            Player:draw()
            love.graphics.setColor(const.BLACK)
            love.graphics.points(0,0)
        Camera:detach()

    love.graphics.setCanvas()

    love.graphics.push()
        love.graphics.setColor(1, 1, 1)
        love.graphics.scale(scale, scale)
        love.graphics.translate(offsetX, offsetY)
        love.graphics.draw(canvas)
    love.graphics.pop()
end

function love.keypressed(key, _, _)
    if key == "escape" then
        love.event.quit()
    elseif key == "f11" then
        local fullscreen = love.window.getFullscreen()
        love.window.setFullscreen(not fullscreen)
    end
end

function love.resize(w, h)
    calculateScale()
end