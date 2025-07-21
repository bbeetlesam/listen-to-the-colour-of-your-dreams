local utils = require("src.utils")

local Player = {}

function Player:load(x, y, playable)
    self.x = x or 0
    self.y = y or 0
    self.targetX = self.x
    self.targetY = self.y
    self.playable = playable

    self.isMoving = false
    self.speed = 16 -- higher is faster
    self.stepSize = 30
end

function Player:update(dt)
    -- if not moving, able to move with AWSD
    if not self.isMoving and self.playable then
        local moveX, moveY = 0, 0
        if love.keyboard.isDown("d") then
            moveX = 1
            moveY = 1
        elseif love.keyboard.isDown("a") then
            moveX = -1
            moveY = -1
        end

        if moveX ~= 0 then
            self.targetX = self.x + moveX * self.stepSize
            self.targetY = self.y + moveY * self.stepSize
            self.isMoving = true
        end
    end

    -- while moving, move towards the target with interpolation (lerp)
    if self.isMoving then
        self.x = self.x + (self.targetX - self.x) * self.speed * dt
        self.y = self.y + (self.targetY - self.y) * self.speed * dt

        -- check if it is close enough to stop.
        if math.abs(self.targetX - self.x) < 0.5 and math.abs(self.targetY - self.y) < 0.5 then
            self.x, self.y = self.targetX, self.targetY -- snap to the final position
            self.isMoving = false
        end
    end
end

function Player:draw()
    love.graphics.push("all")
    love.graphics.setLineWidth(4)
    love.graphics.setColor(utils.rgb(0, 0, 0))
    love.graphics.circle("line", self.x, self.y, 15)
    love.graphics.pop()
end

function Player:getPosition()
    return self.x, self.y
end

return Player