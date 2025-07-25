local utils = {
    draw = {
        stairs = function (x, y, depth, direction, color, size, linewidth)
            local const = require("src.helpers.const")
            depth = depth or 1
            size = size or 32
            linewidth = linewidth or const.LINE_WIDTH
            direction = direction or "right"
            color = color or require("src.states").lineColor

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
            love.graphics.setColor(color)
            love.graphics.line(points)
            love.graphics.pop()
        end,

        mailbox = function (x, y, size)
            local const = require("src.helpers.const")
            local linewidth = const.LINE_WIDTH
            local color = require("src.states").lineColor
            local a, b = 5, 25

            love.graphics.push("all")
            love.graphics.setLineWidth(linewidth)
            love.graphics.setColor(color)
            love.graphics.line({x-a,y, x-a,y-const.TILE_SIZE*1.5}) -- pole
            love.graphics.line({x+a,y, x+a,y-const.TILE_SIZE*1.5}) -- pole
            love.graphics.line({x-b+26,y-const.TILE_SIZE*2, x-b+26,y-const.TILE_SIZE*1.5}) -- vert
            love.graphics.line({x-b+12,y-const.TILE_SIZE*2-12, x+b-12,y-const.TILE_SIZE*2-12}) -- horz
            love.graphics.line({x-b,y-const.TILE_SIZE*2, x-b,y-const.TILE_SIZE*1.5, x+b,y-const.TILE_SIZE*1.5, x+b,y-const.TILE_SIZE*2}) -- mailbox
            love.graphics.arc("line", "open", x - 13, y - const.TILE_SIZE*2, 12, math.rad(-90), math.rad(-180))
            love.graphics.arc("line", "open", x + 13, y - const.TILE_SIZE*2, 12, 0, -math.pi)
            love.graphics.pop()
        end,

        lines = function (points, width, color)
            love.graphics.push("all")
            love.graphics.setLineWidth(width or require("src.helpers.const").LINE_WIDTH)
            love.graphics.setColor(color or require("src.states").lineColor)
            love.graphics.line(points)
            love.graphics.pop()
        end,

        fences = function (x, y, length)
            love.graphics.push("all")
            love.graphics.setLineWidth(require("src.helpers.const").LINE_WIDTH)
            love.graphics.setColor(require("src.states").lineColor)
            for i = 0, length - 1 do
                -- love.graphics.setColor(1, 1, 1)
                -- love.graphics.rectangle("fill", x + 16 + 32*i - 5, y - 32*1.75, 10, 32*1.75)
                -- love.graphics.setColor(require("src.states").lineColor)
                love.graphics.rectangle("line", x + 16 + 32*i - 5, y - 32*1.75, 10, 32*1.75)
            end
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", x, y - 32*0.5 - 5, 32*length, 10)
            love.graphics.rectangle("fill", x, y - 32*1.2 - 5, 32*length, 10)
            love.graphics.setColor(require("src.states").lineColor)
            love.graphics.rectangle("line", x, y - 32*0.5 - 5, 32*length, 10)
            love.graphics.rectangle("line", x, y - 32*1.2 - 5, 32*length, 10)
            love.graphics.pop()
        end,

        arrowSign = function (x, y, directionX)
            love.graphics.push("all")
            love.graphics.setLineWidth(require("src.helpers.const").LINE_WIDTH)
            love.graphics.setColor(require("src.states").lineColor)
            love.graphics.rectangle("line", x - 5, y - 32*2.25, 10, 32*2.25)
            if directionX >= 0 then
                x = x + 3
                love.graphics.line({x + 18,y - 32*2.25, x - 32,y - 32*2.25, x - 32,y - 32*3, x + 18,y - 32*3, x + 32,y - 32*2.625, x + 18,y - 32*2.25})
            end
            love.graphics.pop()
        end,

        bricks = function (x, y, w, h)
            love.graphics.push("all")
            love.graphics.setLineWidth(require("src.helpers.const").LINE_WIDTH)
            love.graphics.setColor(require("src.states").lineColor)
            love.graphics.rectangle("line", x, y - h*32, w*32, h*32)
            for i = 0, h - 1 do
                for j = 0, w - 1 do
                    j = j*32
                    local addX = 0
                    if i % 2 ~= 0 then addX = 16 end
                    love.graphics.line(x + addX + j,y - i*32, x + addX + j,y - i*32 - 32)
                end
                i = i*32
                love.graphics.line(x, y - i, x + w*32, y - i)
            end
            love.graphics.pop()
        end,
    },

    rgb = function (r, g, b, a)
        return {love.math.colorFromBytes(r, g, b, a)}
    end,

    lines = function (points, color)
        love.graphics.push("all")
        love.graphics.setLineWidth(require("src.helpers.const").LINE_WIDTH)
        love.graphics.setColor(color or require("src.states").lineColor)
        love.graphics.line(points)
        love.graphics.pop()
    end,

    lerpColor = function(color1, color2, t)
        t = math.max(0, math.min(1, t)) -- clamp t between 0 and 1
        local newColor = {}
        for i = 1, 4 do
            newColor[i] = color1[i] + (color2[i] - color1[i]) * t
        end
        return newColor
    end,

    coordStr = function (x, y)
        return x .. "," .. y
    end,

    isValueAround = function (value, lower, upper)
        return value >= lower and value <= upper
    end,

    -- ONLY USED FOR DT MEASURED VARIABLES
    ifTimeIs = function (value, num)
        return value >= num and value <= num + 0.1
    end,
}

-- for tilemap debugging
function utils.drawGrid(gridSize, color)
    local const = require("src.helpers.const")
    local screenW, screenH = const.WIDTH, const.HEIGHT
    local centerX, centerY = screenW / 2 - 16, screenH / 2 - 16

    gridSize = gridSize or 32
    color = color or {0.8, 0.8, 0.8, 0.5}

    love.graphics.push()

    love.graphics.translate(centerX, centerY)

    love.graphics.setColor(color)
    love.graphics.setLineWidth(1)

    local maxX = math.ceil(screenW / 2 / gridSize) * gridSize
    local maxY = math.ceil(screenH / 2 / gridSize) * gridSize

    -- vertical lines
    for x = -maxX, maxX, gridSize do
        love.graphics.line(x, -maxY, x, maxY)
    end

    -- horizontal lines
    for y = -maxY, maxY, gridSize do
        love.graphics.line(-maxX, y, maxX, y)
    end

    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.line(-4, 0, 4, 0)
    love.graphics.line(0, -4, 0, 4)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
end

return utils