local Camera = require("src.core.camera")
local Player = require("src.core.player")
local Interactables = require("src.interactables")
local const = require("src.helpers.const")
local utils = require("src.helpers.utils")
local states = require("src.states")
local sounds = require("src.sounds")
local dialogue = require("src.dialogues")

---@class CrowdChase : Act
local act = {}

local img = {
    rock = love.graphics.newImage("assets/img/rock.png"),
    phonebooth = love.graphics.newImage("assets/img/phonebooth.png"),
}

function act:load()
    Player:setPosition(32*120.5, 32*69.5) -- for debugging
    Player:clearWalls()
    Player:addWall(32*290, 32*69)

    Player:clearTriggers()
    Player:clearHotPositions()

    -- initial cutscene
    Player:addTrigger(32*120.5, 32*69.5, {
        mode = 'once',
        onUpdate = function(trigger, _, timer)
            if not trigger.started then
                Player:setPlayable(false); trigger.started = true
            end
            if not trigger.d1 and timer >= 1 then
                dialogue:showTemporary(dialogue.act3[1], 3.5); Player:setDirection(-1); trigger.d1 = true
            end
            if not trigger.d2 and timer >= 4.5 then
                dialogue:showTemporary(dialogue.act3[2], 3.5); trigger.d2 = true
            end
            if not trigger.playable and timer >= 8.25 then
                Player:setPlayable(true); trigger.playable = true
                trigger.isActive = false
                self.isChasing = true
                Player:setSpeed(190)
            end
        end
    })

    -- surprised about the rock
    Player:addTrigger(32*142.5, 32*69.5, {
        mode = 'once',
        onUpdate = function(trigger, _, timer)
            if not trigger.d3 and timer >= 0 then
                dialogue:showTemporary(dialogue.act3[3], 3); trigger.d3 = true
                trigger.isActive = false
            end
        end
    })

    -- surprised about the rock 2nd time
    Player:addTrigger(32*169.5, 32*69.5, {
        mode = 'once',
        onUpdate = function(trigger, _, timer)
            if not trigger.d3 and timer >= 0 then
                dialogue:showTemporary(dialogue.act3[4], 3); trigger.d3 = true
                trigger.isActive = false
            end
        end
    })

    -- hide there
    Player:addTrigger(32*257.5, 32*69.5, {
        mode = 'once',
        onUpdate = function(trigger, _, timer)
            if not trigger.d and timer >= 0 then
                dialogue:showTemporary(dialogue.act3[7], 3); trigger.d = true
                trigger.isActive = false
            end
        end
    })

    self.isHiding = false
    self.isChasing = false
    self.isCaught = false
    self.crowd = {
        image = nil,
        pos = {x = 32*100, y = 32*70},
        drawRect = function (x, y)
            love.graphics.setColor(1, 0, 0)
            love.graphics.line({x,y, x-32*9,y, x-32*9,y-32*5, x,y-32*5, x,y})
            love.graphics.setColor(0, 0, 0)
        end
    }

    -- set obstacles
    self.obstacles = {
        {
            x = 32*150, y = 32*69, w = 32, h = 32, hp = 6,
            isBroken = false, wallKeys = {}
        }, {
            x = 32*180, y = 32*69, w = 32, h = 32, hp = 6,
            isBroken = false, wallKeys = {}
        }, {
            x = 32*195, y = 32*69, w = 32, h = 32, hp = 7,
            isBroken = false, wallKeys = {}
        }, {
            x = 32*215, y = 32*69, w = 32, h = 32, hp = 7,
            isBroken = false, wallKeys = {}
        }, {
            x = 32*230, y = 32*69, w = 32, h = 32, hp = 8,
            isBroken = false, wallKeys = {}
        }, {
            x = 32*240, y = 32*69, w = 32, h = 32, hp = 9,
            isBroken = false, wallKeys = {}
        }, {
            x = 32*248, y = 32*69, w = 32, h = 32, hp = 11,
            isBroken = false, wallKeys = {}
        },
    }
    -- add wall for each obstacle
    for _, obs in ipairs(self.obstacles) do
        local key = obs.x .. "," .. obs.y
        table.insert(obs.wallKeys, key)
        Player:addWall(obs.x, obs.y)
    end

    Interactables:clear()
    Interactables:add("phone-booth", 32*270.5, 32*69.5, {
        detectionMethod = 'on_spot',
        isActive = true,
        type = 'toggle',
        promptMessage = "[ENTER] to hide.",
        onInteract = function(toggle)
            self.isHiding = toggle
            Player:setPlayable(not toggle)
            if toggle then
                sounds.doorClose:play()
                if self.isChasing then Interactables:deactivate("phone-booth") end
                Interactables:setPrompt("phone-booth", "[ENTER] to get out.")
            else
                Interactables:setPrompt("phone-booth", "[ENTER] to hide.")
            end
        end
    })
end

function act:update(dt)
    Player:update(dt)

    local px, py = Player:getPosition()
    Camera:setPosition(math.max(math.min(px, 32*270.5), 32*120.5), py - 32*3)

    -- chasing
    if self.isChasing then
        self.crowd.pos.x = self.crowd.pos.x + dt * 165
        if self.crowd.pos.x - 32*9 <= px and self.crowd.pos.x >= px + 16 and not self.isHiding then
            self.isCaught = true
        end

        -- done chasing
        if self.crowd.pos.x >= 32*304 then
            Interactables:activate("phone-booth")
            Player:setSpeed(150)
            dialogue:showTemporary(dialogue.act3[5], 4.5);

            Player:clearTriggers()
            -- should i go back left
            Player:addTrigger(32*289.5, 32*69.5, {
                mode = 'once',
                onUpdate = function(trigger, _, timer)
                    if not trigger.d1 and timer >= 0 then
                        dialogue:showTemporary(dialogue.act3[6], 4); trigger.d1 = true
                        trigger.isActive = false
                    end
                end
            })

            -- move to act 4
            Player:addTrigger(32*120.5, 32*69.5, {
                mode = 'once',
                onUpdate = function(trigger, _, _)
                    if trigger then require("src.acts"):load("going-home") end
                end
            })

            self.isChasing = false
        end
    end
end

function act:draw()
    Camera:attach()
        utils.lines({32*0,32*70, 32*300,32*70}) -- ground line 2

        -- stuff
        utils.draw.stairs(32*30, 0, 70)
        utils.draw.arrowSign(32*135, 32*70, 1)
        utils.draw.arrowSign(32*186.75, 32*70, 1)
        utils.draw.arrowSign(32*245.25, 32*70, 1)
        utils.draw.fences(32*141, 32*70, 20)
        utils.draw.fences(32*177, 32*70, 20)
        utils.draw.fences(32*212, 32*70, 12)
        utils.draw.bricks(32*163, 32*70, 12, 8)
        for _, obs in ipairs(self.obstacles) do
            if not obs.isBroken then
                love.graphics.setColor(states.lineColor)
                love.graphics.draw(img.rock, obs.x, obs.y, 0, 1/2, nil, 0, img.rock:getHeight()*2/3)
                love.graphics.setColor(1, 1, 1)
            end
        end
        love.graphics.draw(img.phonebooth, 32*270.5, 32*70 - 2, 0, 1/2, nil, img.phonebooth:getWidth()/2, img.phonebooth:getHeight())

        Interactables:drawDebug()
        Player:drawWallDebug()
        Player:drawHotPositionDebug()
        Player:drawTriggerDebug()
        Player:draw()

        -- overlap player if hiding
        if self.isHiding then
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(img.phonebooth, 32*270.5, 32*70 - 2, 0, 1/2, nil, img.phonebooth:getWidth()/2, img.phonebooth:getHeight())
        end

        -- the crowd
        self.crowd.drawRect(self.crowd.pos.x, self.crowd.pos.y)
    Camera:detach()

    -- interactable prompt
    local obstacle = self:getObstacleInFront()
    local interactable = Interactables:getInteractableObject()
    local promptText
    if obstacle then
        promptText = "Spam [ENTER] to destroy."
    elseif interactable then
        promptText = interactable.promptMessage
    end
    if promptText then
        local posY = dialogue.isShowing and const.HEIGHT - 60 - dialogue.promptFont:getHeight() or const.HEIGHT - 50
        love.graphics.setFont(dialogue.promptFont)
        love.graphics.setColor(states.lineColor)
        love.graphics.print(promptText, const.WIDTH/2, posY, 0, 1, 1, dialogue.promptFont:getWidth(promptText)/2)
    end
end

function act:keypressed(key, _)
    if key == 'return' then
        local obstacle = self:getObstacleInFront()
        if obstacle then
            obstacle.hp = obstacle.hp - 1
            if obstacle.hp <= 0 then
                obstacle.isBroken = true
                Player:clearWalls(unpack(obstacle.wallKeys))
                -- sounds.obstacleBreak:play()
            else
                sounds.rockHit:play()
                sounds.rockHit:setVolume(0.35)
            end
        else
            Interactables:interact()
        end
    end
end

-- used for obstacles
function act:getObstacleInFront()
    local px, py = Player:getPosition()
    local pDir = Player:getDirectionX()
    local nextTileCenterX = px + pDir * 32
    local nextTileCenterY = py

    local wallX = math.floor(nextTileCenterX / 32) * 32
    local wallY = math.floor(nextTileCenterY / 32) * 32

    for _, obstacle in ipairs(self.obstacles) do
        if not obstacle.isBroken and obstacle.x == wallX and obstacle.y == wallY then
            return obstacle
        end
    end
    return nil
end

return act