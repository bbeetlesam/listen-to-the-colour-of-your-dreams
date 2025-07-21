local const = require("src.helpers.const")

local Camera = {}

function Camera:load(x, y, w, h, zoom)
    self.x = x or 0
    self.y = y or 0
    self.w = w or const.WIDTH
    self.h = h or const.HEIGHT
    self.zoom = zoom or 1
end

function Camera:setPosition(x, y)
    self.x = x or 0
    self.y = y or 0
end

function Camera:getPosition()
    return self.x, self.y
end

function Camera:setZoom(zoom)
    self.zoom = zoom or 1
end

function Camera:setSize(w, h)
    self.w = w or love.graphics.getWidth()
    self.h = h or love.graphics.getHeight()
end

function Camera:attach()
    love.graphics.push()

    -- translate to center screen
    love.graphics.translate(self.w/2, self.h/2)

    -- scale/zoom based on the point
    love.graphics.scale(self.zoom, self.zoom)

    -- return translate, then move view based on camera position
    love.graphics.translate(-self.x, -self.y)
end

function Camera:detach()
    love.graphics.pop()
end

return Camera