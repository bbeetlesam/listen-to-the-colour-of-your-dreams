local utils = {
    rgb = function (r, g, b, a)
        return love.math.colorFromBytes(r, g, b, a)
    end,

    lines = function (points, color)
        love.graphics.push("all")
        love.graphics.setLineWidth(require("src.helpers.const").LINE_WIDTH)
        love.graphics.setColor(color or {0, 0, 0})
        love.graphics.line(points)
        love.graphics.pop()
    end,

    drawStairs = function (x, y, depth, direction, color, size, linewidth)
        local const = require("src.helpers.const")
        depth = depth or 1
        size = size or 32
        linewidth = linewidth or const.LINE_WIDTH
        direction = direction or "right"
        color = color or const.BLACK

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
}

return utils