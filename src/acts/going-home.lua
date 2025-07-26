local Camera = require("src.core.camera")
local Player = require("src.core.player")
local Interactables = require("src.interactables")
local const = require("src.helpers.const")
local utils = require("src.helpers.utils")
local states = require("src.states")
local sounds = require("src.core.sounds")
local dialogue = require("src.dialogues")

---@class GoHome : Act
local act = {}

local img = {
    door = love.graphics.newImage("assets/img/door.png"),
}

function act:load()
    Player:clearWalls()
    Player:addWall(32*20, 32*-1) -- right limit wall
    Player:addWall(32*-61, 32*-1) -- left limit wall
    Player:addWall(32*-41, 32*-1, 2, 1) -- door wall
    Player:addWall(32*-60, 32*-3, 6, 3) -- bed wall

    Player:clearTriggers()
    Player:clearHotPositions()
    Player:setPlayer(16*1, -16*1, true, "linear")
    Camera:setPosition(-16*0, 0)

    self.titleFont = love.graphics.newFont("assets/font/Helvetica Bold Condensed.otf", 60)
    self.titleFont2 = love.graphics.newFont("assets/font/Helvetica Bold Condensed.otf", 25)
    self.promptFont = love.graphics.newFont("assets/font/BalsamiqSansRegular.ttf", 20)
    self.serialFont = love.graphics.newFont("assets/font/CrashNumbering.ttf", 30)

    self.title = love.graphics.newText(self.titleFont, nil)
    self.title:set({utils.rgb(160, 160, 160), "The COLOUR"})

    self.playable = true
    self.hasStarted = false
    self.enterHouse = false
    self.sleeping = false
    self.timer = 0
    self.colorProgress = 0

    Interactables:clear()
    Interactables:add("door", 32*-41, 32*-1, {
        type = 'toggle',
        w = 32*2, h = 32, isActive = true,
        promptMessage = "[ENTER] to Open.",
        onInteract = function(isOpen)
            if not self.enterHouse then
                self.enterHouse = true
                dialogue:showTemporary(dialogue.act1[1], 3.5)
            end
            if isOpen then
                Player:clearWalls(utils.coordStr(32*-41, 32*-1), utils.coordStr(32*-40, 32*-1))
                Interactables:setPrompt("door", "[ENTER] to Close.")
                sounds.doorOpen:setVolume(1)
                sounds.doorOpen:play()
                return
            end
            Player:addWall(32*-41, 32*-1, 2, 1)
            Interactables:setPrompt("door", "[ENTER] to Open.")
            sounds.doorClose:setVolume(1)
            sounds.doorClose:play()
        end
    })
    Interactables:add("bed", 32*-60, 32*-3, {
        type = 'callout',
        w = 32*6, h = 32*3, isActive = true,
        promptMessage = "[ENTER] to Sleep.",
        onInteract = function()
            if Interactables:getState("door") then
                dialogue:showTemporary("Close the door first.", 2)
            else
                Interactables:deactivate("bed")
                self.sleeping = true
                dialogue:showTemporary(dialogue.act1[2], 3.5)
                self.timer = 0
            end
        end
    })
end

function act:update(dt)
    Player:update(dt)
    Player:setPlayable(self.playable)

    local px, py = Player:getPosition()
    Camera:setPosition(math.max(32*-40.5, math.min(px, 32*0.5)), py - 32*3)

    if love.keyboard.isDown("a", "d") then
        if not self.hasStarted then
            self.hasStarted = true
        end
    end

    if self.sleeping then
        self.timer = self.timer + dt
        self.playable = false

        if self.timer >= 7 then self.colorProgress = self.colorProgress - dt*0.45 end
        if self.timer >= 22.75 then self.playable = true end
        if utils.isValueAround(self.timer, 3.5, 3.6) then dialogue:showTemporary(dialogue.act1[3], 3.5)
        elseif utils.isValueAround(self.timer, 12, 12.1) then dialogue:showTemporary(dialogue.act1[4], 3.5)
        elseif utils.isValueAround(self.timer, 15.5, 15.6) then dialogue:showTemporary(dialogue.act1[5], 3.5)
        elseif utils.isValueAround(self.timer, 19, 19.1) then dialogue:showTemporary(dialogue.act1[6], 3.5)
        end

        -- going outside (move to act 2)
        if px == 32*-38 - 16 then
            sounds.doorClose:play()
            require("src.acts"):load("going-outside")
        end
    else
        local startDist, endDist = 0, -32*39
        self.colorProgress = (px - startDist) / (endDist - startDist)
    end
    states.bgColor = utils.lerpColor(const.BROKEN_WHITE, const.BLACK, self.colorProgress)
    states.lineColor = utils.lerpColor(const.BLACK, const.BROKEN_WHITE, self.colorProgress)
end

function act:draw()
    Camera:attach()
        utils.lines({-32*100,0, 32*20.5,0}) -- ground line
        utils.lines({32*20.5,0, 32*20.5,-32*15}) -- right limit

        -- house
        utils.lines({-32*40,0, -32*40,-32*8, -32*60,-32*8, -32*60,0})

        -- stuff
        utils.draw.mailbox(32*-36.5, 0)
        if not Interactables:getState("door") then
            utils.draw.lines({-32*40,0, -32*40,32*-4}, 8)
        else
            love.graphics.setColor(states.lineColor)
            love.graphics.draw(img.door, 32*-42, 32*-4, 0, 1/2, nil)
            love.graphics.setColor(1, 1, 1)
        end

        Interactables:drawDebug()
        Player:drawWallDebug()
        Player:draw()

        -- game title
        love.graphics.push()
        love.graphics.translate(0, -270)
        love.graphics.rotate(-0.02)
        love.graphics.draw(self.title, 0, 0, 0, 1, 1, self.title:getWidth()/2, self.title:getHeight()/2)
        love.graphics.setColor(utils.rgb(180, 180, 180))
        love.graphics.setFont(self.titleFont2)
        love.graphics.print("listen to", -self.title:getWidth()/2, -48, 0, 1, 1, 0, self.titleFont2:getHeight()/2)
        love.graphics.print("of your dreams", -self.title:getWidth()/2, 30, 0, 1, 1, 0, self.titleFont2:getHeight()/2)
        love.graphics.pop()

        love.graphics.setColor(utils.rgb(180, 180, 180))
        love.graphics.setFont(self.serialFont)
        love.graphics.print("Q" .. string.format("%07d", states.playCount), const.WIDTH/2 - 250, const.HEIGHT/2 - 110 - 32*3,
            0.08, 1, 1, 0, self.serialFont:getHeight()/2
        )
    Camera:detach()

    -- ui and instructions
    love.graphics.setFont(self.promptFont)
    love.graphics.setColor(states.lineColor)

    if not self.hasStarted then
        local message = "Press A or D to move"
        love.graphics.print(message, const.WIDTH/2, const.HEIGHT - 50, 0, 1, 1, self.promptFont:getWidth(message)/2)
    end

    -- interactable prompt
    local interactable = Interactables:getInteractableObject()
    if interactable then
        local promptText = interactable.promptMessage
        local posY = dialogue.isShowing and const.HEIGHT - 60 - self.promptFont:getHeight() or const.HEIGHT - 50
        love.graphics.print(promptText, const.WIDTH/2, posY, 0, 1, 1, self.promptFont:getWidth(promptText)/2)
    end
end

function act:keypressed(key, isrepeat)
    if key == 'return' then
        Interactables:interact()
    end
end

return act