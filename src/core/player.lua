local const = require("src.helpers.const")

local Player = {}

Player.walls = {} -- using a table as a set for fast lookups. key format: "x,y"
Player.hotPositions = {} -- [key] = { right = "movement_type", left = "movement_type" }
Player.triggers = {}
Player.onWallHitCallback = nil

function Player:load(x, y, playable, type)
    self.x = x or 0
    self.y = y or 0
    self.targetX = self.x
    self.targetY = self.y

    self.playable = playable
    self.movement = type or "linear" -- "linear" | "diagonal_normal" | "diagonal_inverted"
    self.direction = -1

    self.isMoving = false
    self.speed = 150 -- higher is faster
    self.stepSize = 32

    self.onWallHitCallback = nil
    self.hotPositions = {}
    self.triggers = {}

    self.image = love.graphics.newImage("assets/img/player-light-bold.png")
    self.stepSound = love.audio.newSource("assets/sfx/" .. "walk-step.wav", "static")
end

function Player:update(dt)
    -- Update active triggers first
    for _, trigger in pairs(self.triggers) do
        if trigger.isActive then
            trigger.timer = trigger.timer + dt
            if trigger.onUpdate then
                -- The onUpdate function can set isActive to false to stop the trigger
                trigger.onUpdate(trigger, dt, trigger.timer)
            end
        end
    end

    -- if not moving, able to move with AWSD
    if not self.isMoving and self.playable then
        -- Check for hot positions and update movement type if necessary
        local key = self.x .. "," .. self.y
        local rules = self.hotPositions[key]
        if rules then
            if love.keyboard.isDown("d") and rules.right then
                self:setMovement(rules.right)
            elseif love.keyboard.isDown("a") and rules.left then
                self:setMovement(rules.left)
            end
        end

        local moveX, moveY = 0, 0
        if love.keyboard.isDown("d") then
            moveX = 1
            self.direction = 1
        elseif love.keyboard.isDown("a") then
            moveX = -1
            self.direction = -1
        end

        if moveX ~= 0 then
            -- calculate vertical movement based on the current movement type
            if self.movement == "diagonal_normal" then
                moveY = moveX
            elseif self.movement == "diagonal_inverted" then
                moveY = -moveX
            end

            -- Player is about to move. Check if they are leaving a trigger spot.
            local currentKey = self.x .. "," .. self.y
            local leavingTrigger = self.triggers[currentKey]
            if leavingTrigger then
                leavingTrigger.playerIsOnSpot = false
            end

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

            -- Player has just landed. Check for triggers at the new position.
            local newKey = self.x .. "," .. self.y
            local landingTrigger = self.triggers[newKey]
            if landingTrigger then
                if landingTrigger.mode == 'once' and not landingTrigger.hasBeenTriggered then
                    landingTrigger.hasBeenTriggered = true
                    landingTrigger.isActive = true
                    landingTrigger.timer = 0
                elseif landingTrigger.mode == 'onEnter' and not landingTrigger.playerIsOnSpot then
                    landingTrigger.playerIsOnSpot = true
                    landingTrigger.isActive = true
                    landingTrigger.timer = 0
                end
            end

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

function Player:draw(bool)
    local states = require("src.states")
    local r, g, b, a = unpack(states.lineColor)

    love.graphics.push("all")
    love.graphics.setColor(r, g, b, a)
    love.graphics.draw(self.image, self.x - 0, self.y + 16, 0, 1/2*self.direction, 1/2, self.image:getWidth()/2, self.image:getHeight())

    -- collider debug
    if bool then
        love.graphics.setColor(1,0,0)
        love.graphics.circle("line", self.x, self.y, 8)
    end
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

function Player:removeHotPosition(x, y)
    local key = x .. "," .. y
    self.hotPositions[key] = nil
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

-- for debugging
function Player:drawHotPositionDebug()
    love.graphics.push("all")
    love.graphics.setColor(0, 0, 1, 0.8) -- Blue
    for key, _ in pairs(self.hotPositions) do
        local parts = {}
        for part in string.gmatch(key, "[^,]+") do
            table.insert(parts, tonumber(part))
        end
        local x, y = parts[1], parts[2]
        love.graphics.circle("fill", x, y, 8)
    end
    love.graphics.pop()
end

-- for debugging
function Player:drawTriggerDebug()
    love.graphics.push("all")
    love.graphics.setColor(0, 1, 0, 0.8) -- Green
    for key, _ in pairs(self.triggers) do
        local parts = {}
        for part in string.gmatch(key, "[^,]+") do
            table.insert(parts, tonumber(part))
        end
        local x, y = parts[1], parts[2]
        if x and y then
            love.graphics.circle("fill", x, y, 8)
        end
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

---@param rules table { right : "linear"|"diagonal_normal"|"diagonal_inverted", left : "linear"|"diagonal_normal"|"diagonal_inverted" }
function Player:addHotPosition(x, y, rules)
    local key = x .. "," .. y
    self.hotPositions[key] = rules
end

---@param options table { onUpdate = fun(trigger:table, dt:number, timer:number), mode = "once"|"onEnter" }
function Player:addTrigger(x, y, options)
    local key = x .. "," .. y
    local newTrigger = {
        key = key,
        onUpdate = options.onUpdate,
        mode = options.mode or 'onEnter',
        -- state
        isActive = false,
        hasBeenTriggered = false,
        playerIsOnSpot = false,
        timer = 0
    }
    self.triggers[key] = newTrigger

    -- immediately activate the trigger if the player is already on the spot when it's created
    -- fixes triggers at the start of an act
    if self.x == x and self.y == y then
        if newTrigger.mode == 'once' and not newTrigger.hasBeenTriggered then
            newTrigger.hasBeenTriggered, newTrigger.isActive, newTrigger.timer = true, true, 0
        elseif newTrigger.mode == 'onEnter' and not newTrigger.playerIsOnSpot then
            newTrigger.playerIsOnSpot, newTrigger.isActive, newTrigger.timer = true, true, 0
        end
    end
end

function Player:clearHotPositions()
    self.hotPositions = {}
end

---@param type table {"linear" | "diagonal_normal" | "diagonal_inverted"}
function Player:setMovement(type)
    self.movement = type or "linear"
end

function Player:clearTriggers()
    self.triggers = {}
end

function Player:setPlayer(x, y, playable, type)
    self.x = x or 0
    self.y = y or 0
    self.targetX = self.x
    self.targetY = self.y
    self.playable = playable
    self.movement = type or "linear"
    self.direction = -1
end

function Player:setPosition(x, y)
    self.x = x
    self.y = y
end

function Player:setDirection(str)
    self.direction = str == "right" and 1 or str == "left" and -1 or -1
end

function Player:setPlayable(bool)
    self.playable = bool
end

function Player:setSpeed(speed)
    self.speed = speed or 150
end

function Player:getPosF()
    local n = self.x / 32
    local m = self.y / 32
    return "32*" .. tostring(n) .. ", " .. "32*" .. tostring(m)
end

return Player