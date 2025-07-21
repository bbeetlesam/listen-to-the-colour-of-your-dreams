local utils = {
    rgb = function (r, g, b, a)
        return love.math.colorFromBytes(r, g, b, a)
    end,

    lines = function (points, color)
        love.graphics.push("all")
        love.graphics.setLineWidth(require("src.const").LINE_WIDTH)
        love.graphics.setColor(color or {0, 0, 0})
        love.graphics.line(points)
        love.graphics.pop()
    end
}

return utils