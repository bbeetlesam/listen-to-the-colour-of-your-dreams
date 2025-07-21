local utils = require("src.helpers.utils")

local Player = {}

function Player:load(x, y, playable)
    self.x = x or 0
    self.y = y or 0
    self.targetX = self.x
    self.targetY = self.y
    self.playable = playable

    self.isMoving = false
    self.speed = 150 -- higher is faster
    self.stepSize = 32

    self.stepSound = love.audio.newSource("assets/sfx/" .. "walk-step.wav", "static")
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

    -- while moving, move towards the target with linear interpolation
    if self.isMoving then
        local dx = self.targetX - self.x
        local dy = self.targetY - self.y
        local dist = math.sqrt(dx * dx + dy * dy)

        if dist < self.speed * dt then
            self.x, self.y = self.targetX, self.targetY -- snap to the final position
            self.isMoving = false

            -- add stepping sound
            self.stepSound:play()
            self.stepSound:setVolume(0.3)
        else
            -- move towards the target at a constant speed.
            local dirX = dx / dist
            local dirY = dy / dist
            self.x = self.x + dirX * self.speed * dt
            self.y = self.y + dirY * self.speed * dt
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