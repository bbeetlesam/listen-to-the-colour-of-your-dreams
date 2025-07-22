local const = require("src.helpers.const")

local Player = {}

Player.walls = {} -- using a table as a set for fast lookups. Key format: "x,y"
Player.onWallHitCallback = nil

function Player:load(x, y, playable, type)
    self.x = x or 0
    self.y = y or 0
    self.targetX = self.x
    self.targetY = self.y

    self.playable = playable
    self.movement = type or "diagonal"
    self.direction = -1

    self.isMoving = false
    self.speed = 400 -- 150 - higher is faster
    self.stepSize = 32

    self.onWallHitCallback = nil

    self.image = love.graphics.newImage("assets/img/player0.png")
    self.stepSound = love.audio.newSource("assets/sfx/" .. "walk-step.wav", "static")
end

function Player:update(dt)
    -- if not moving, able to move with AWSD
    if not self.isMoving and self.playable then
        local moveX, moveY = 0, 0
        if love.keyboard.isDown("d") then
            if self.movement == "diagonal" then
                moveX = 1
                moveY = 1
            elseif self.movement == "linear" then
                moveX = 1
            end
            self.direction = 1
        elseif love.keyboard.isDown("a") then
            if self.movement == "diagonal" then
                moveX = -1
                moveY = -1
            elseif self.movement == "linear" then
                moveX = -1
            end
            self.direction = -1
        end

        if moveX ~= 0 then
            local nextX = self.x + moveX * self.stepSize
            local nextY = self.y + moveY * self.stepSize

            -- Check for a wall at the next position
            if self:isWallAt(nextX, nextY) then
                if self.onWallHitCallback then
                    self.onWallHitCallback(nextX, nextY)
                end
            else
                self.targetX = nextX
                self.targetY = nextY
                self.isMoving = true
            end
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
    love.graphics.draw(self.image, self.x - 0, self.y + 16, 0, 1/2*self.direction, 1/2, self.image:getWidth()/2, self.image:getHeight())

    -- collider debug
    -- love.graphics.setColor(1,0,0)
    -- love.graphics.rectangle("line", self.x-16, self.y-16, 32, 32)
    love.graphics.pop()
end

function Player:getPosition()
    return self.x, self.y
end

function Player:getDirectionX()
    return self.direction
end

function Player:addWall(x, y, w, h)
    local step = const.TILE_SIZE
    w = w or 1
    h = h or 1

    local startX = math.floor(x / step) * step
    local startY = math.floor(y / step) * step

    local dirX = w > 0 and 1 or -1
    local dirY = h > 0 and 1 or -1

    for i = 0, math.abs(w) - 1 do
        for j = 0, math.abs(h) - 1 do
            local key = (startX + i * dirX * step) .. "," .. (startY + j * dirY * step)
            self.walls[key] = true
        end
    end
end

function Player:isWallAt(x, y)
    local step = const.TILE_SIZE
    local gridX = math.floor(x / step) * step
    local gridY = math.floor(y / step) * step
    local key = gridX .. "," .. gridY
    return self.walls[key] == true
end

-- for debugging
function Player:drawWallDebug()
    love.graphics.push("all")
    love.graphics.setColor(1, 0, 0, 0.4)
    for key, _ in pairs(self.walls) do
        local parts = {}
        for part in string.gmatch(key, "[^,]+") do
            table.insert(parts, tonumber(part))
        end
        local x, y = parts[1], parts[2]
        love.graphics.rectangle("fill", x, y, 32, 32)
    end
    love.graphics.pop()
end

function Player:clearWalls(...)
    local indices_to_remove = {...}
    if #indices_to_remove > 0 then
        for _, index in ipairs(indices_to_remove) do
            self.walls[index] = nil
        end
    else
        self.walls = {}
    end
end

function Player:onWallHit(callback)
    self.onWallHitCallback = callback
end

-- type: "diagonal" or "linear"
function Player:setMovement(type)
    self.movement = type or "diagonal"
end

function Player:setPlayer(x, y, playable, type)
    self.x = x or 0
    self.y = y or 0
    self.targetX = self.x
    self.targetY = self.y
    self.playable = playable
    self.movement = type or "diagonal"
end

return Player