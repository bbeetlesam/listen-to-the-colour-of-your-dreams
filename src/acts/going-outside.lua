local Camera = require("src.core.camera")
local Player = require("src.core.player")
local Interactables = require("src.interactables")
local const = require("src.helpers.const")
local utils = require("src.helpers.utils")
local states = require("src.states")
local sounds = require("src.core.sounds")
local dialogue = require("src.dialogues")

---@class GoOutside : Act
local act = {}

-- local img = {
--     door = love.graphics.newImage("assets/img/door-black.png"),
-- }

function act:load()
    -- Player:setPlayer(32*10.5, 32*-0.5, 1, "linear") -- for debugging
    Player:clearWalls()
    Player:addWall(32*-40, 32*-1) -- house wall

    Player:clearTriggers()
    Player:clearHotPositions()
    -- first stair encounter
    Player:addHotPosition(32*29.5, 32*-0.5, {
        right = "diagonal_normal",
        left = "linear"
    })
    Player:addHotPosition(32*99.5, 32*69.5, {
        right = "linear",
        left = "diagonal_normal"
    })

    -- initial cutscene after going outside
    Player:addTrigger(32*-38.5, 32*-0.5, {
        mode = 'once',
        onUpdate = function(trigger, _, timer)
            if not trigger.started then
                Player:setPlayable(false); trigger.started = true
            end
            if not trigger.d1 and timer >= 1 then
                dialogue:showTemporary(dialogue.act2[1], 3.5); trigger.d1 = true
            end
            if not trigger.d2 and timer >= 4.5 then
                dialogue:showTemporary(dialogue.act2[2], 4); trigger.d2 = true
            end
            if not trigger.playable and timer >= 9 then
                Player:setPlayable(true); trigger.playable = true
                trigger.isActive = false
            end
        end
    })

    -- surprised about the stairway
    Player:addTrigger(32*14.5, 32*-0.5, {
        mode = 'once',
        onUpdate = function(trigger, _, timer)
            if not trigger.d3 and timer >= 0 then
                dialogue:showTemporary(dialogue.act2[3], 3); trigger.d3 = true
            end
            if not trigger.d4 and timer >= 3 then
                dialogue:showTemporary(dialogue.act2[4], 3); trigger.d4 = true
                trigger.isActive = false
            end
        end
    })

    -- when will i hit the fucking bottom
    Player:addTrigger(32*65.5, 32*35.5, {
        mode = 'once',
        onUpdate = function(trigger, _, timer)
            if not trigger.d5 and timer >= 0 then
                dialogue:showTemporary(dialogue.act2[5], 4.5); trigger.d5 = true
                trigger.isActive = false
            end
        end
    })

    -- a hard day's night?? act
    Player:addTrigger(32*120.5, 32*69.5, {
        mode = 'once',
        onUpdate = function(trigger, _, _)
            if trigger then require("src.acts"):load("crowd-chase") end
        end
    })

    Interactables:clear()
end

function act:update(dt)
    Player:update(dt)

    local px, py = Player:getPosition()
    Camera:setPosition(px, py - 32*3)
end

function act:draw()
    Camera:attach()
        utils.lines({-32*100,0, 32*30,0}) -- ground line 1
        utils.lines({32*0,32*70, 32*150,32*70}) -- ground line 2
        utils.lines({-32*40,0, -32*40,-32*8, -32*60,-32*8, -32*60,0}) -- house

        -- stuff
        utils.draw.mailbox(32*-36.5, 0)
        utils.draw.lines({-32*40,0, -32*40,32*-4}, 8) -- door outline
        utils.draw.arrowSign(32*135, 32*70, 1)

        utils.draw.stairs(32*30, 0, 70)

        Interactables:drawDebug()
        Player:drawWallDebug()
        Player:drawHotPositionDebug()
        Player:drawTriggerDebug()
        Player:draw()
    Camera:detach()
end

return act