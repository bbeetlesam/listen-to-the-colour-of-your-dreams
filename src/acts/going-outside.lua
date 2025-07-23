local Camera = require("src.core.camera")
local Player = require("src.core.player")
local Interactables = require("src.interactables")
local const = require("src.helpers.const")
local utils = require("src.helpers.utils")
local states = require("src.states")
local sounds = require("src.sounds")
local dialogue = require("src.dialogues")

---@class GoOutside : Act
local act = {}

-- local img = {
--     door = love.graphics.newImage("assets/img/door-black.png"),
-- }

function act:load()
    -- Player:setPlayer(16*1, -16*1, true, "linear") -- for debugging this act
    Player:clearWalls()
    Player:addWall(32*-40, 32*-1) -- house wall

    Player:clearHotPositions()
    Player:addHotPosition(32*29.5, 32*-0.5, {
        right = "diagonal",
        left = "linear"
    })

    Interactables:clear()

    self.timer = 0
    self.playable = false

    self.eventTimeline = {
        {time = 1, message = dialogue.act2[1], duration = 3.5, triggered = false},
        {time = 4.5, message = dialogue.act2[2], duration = 4, triggered = false},
        {time = 9, action = function(self) self.playable = true end, triggered = false},
    }
end

function act:update(dt)
    Player:update(dt)
    Player:setPlayable(self.playable)

    local px, py = Player:getPosition()
    Camera:setPosition(px, py - 32*3)

    self.timer = self.timer + dt
    for _, event in ipairs(self.eventTimeline) do
        if not event.triggered and self.timer >= event.time then
            if event.message then
                dialogue:showTemporary(event.message, event.duration)
            end
            if event.action then
                event.action(self)
            end
            event.triggered = true
        end
    end
end

function act:draw()
    Camera:attach()
        utils.lines({-32*100,0, 32*30,0}) -- ground line
        utils.lines({-32*40,0, -32*40,-32*8, -32*60,-32*8, -32*60,0}) -- house

        -- stuff
        utils.draw.mailbox(32*-36.5, 0)
        utils.draw.lines({-32*40,0, -32*40,32*-4}, 8) -- door outline

        utils.draw.stairs(32*30, 0, 45)

        Interactables:drawDebug()
        Player:drawWallDebug()
        -- Player:drawHotPositionDebug()
        Player:draw()
    Camera:detach()
end

return act