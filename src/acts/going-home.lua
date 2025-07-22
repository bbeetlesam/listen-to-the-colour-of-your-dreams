local Camera = require("src.core.camera")
local Player = require("src.core.player")
local Interactables = require("src.interactables")
local const = require("src.helpers.const")
local utils = require("src.helpers.utils")
local states = require("src.states")

---@class Opening : Act
local act = {}

function act:load()
    Player:clearWalls()
    Player:addWall(32*20, 32*-1) -- right limit wall
    Player:addWall(32*-61, 32*-1) -- left limit wall
    Player:addWall(32*-41, 32*-1, 2, 1) -- door wall

    Player:setPlayer(16*1, -16*1, true, "linear")
    Camera:setPosition(-16*0, 0)

    self.titleFont = love.graphics.newFont("assets/font/Helvetica Bold Condensed.otf", 60)
    self.titleFont2 = love.graphics.newFont("assets/font/Helvetica Bold Condensed.otf", 25)
    self.textFont = love.graphics.newFont("assets/font/BalsamiqSansRegular.ttf", 25)
    self.serialFont = love.graphics.newFont("assets/font/CrashNumbering.ttf", 30)

    self.title = love.graphics.newText(self.titleFont, nil)
    self.title:set({utils.rgb(160, 160, 160), "The COLOUR"})

    self.hasStarted = false

    Interactables:clear()
    Interactables:add("door", 32*-41, 32*-1, {
        type = 'toggle',
        w = 32*2, h = 32,
        promptMessage = "[ENTER] to Open.",
        onInteract = function(isOpen)
            if isOpen then
                Player:clearWalls(utils.coordStr(32*-41, 32*-1), utils.coordStr(32*-40, 32*-1))
                Interactables:setPrompt("door", "[ENTER] to Close.")
                return
            end
            Player:addWall(32*-41, 32*-1, 2, 1)
            Interactables:setPrompt("door", "[ENTER] to Open.")
        end
    })
end

function act:update(dt)
    Player:update(dt)

    local px, py = Player:getPosition()
    Camera:setPosition(math.max(32*-40.5, math.min(px, 16)), py - 32*3)

    if love.keyboard.isDown("a", "d") then
        if not self.hasStarted then
            self.hasStarted = true
        end
    end

    -- color changing
    local startDist = 0
    local endDist = -32*39
    local progress = (px - startDist) / (endDist - startDist)
    states.bgColor = utils.lerpColor(const.BROKEN_WHITE, const.BLACK, progress)
    states.lineColor = utils.lerpColor(const.BLACK, const.BROKEN_WHITE, progress)

    print("Camera: " .. Camera:getPosition())
    print("Player: " .. Player:getPosition())
end

function act:draw()
    Camera:attach()
        utils.lines({-32*100,0, 32*20.5,0}) -- ground line
        utils.lines({32*20.5,0, 32*20.5,-32*15}) -- right limit

        -- house
        utils.lines({-32*40,0, -32*40,-32*8, -32*60,-32*8, -32*60,0})

        -- decors
        utils.draw.mailbox(32*-36.5, 0)

        Interactables:drawDebug()
        Player:drawWallDebug()
        Player:draw()

        -- game title
        love.graphics.push()
        love.graphics.translate(0, -230)
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
    love.graphics.setFont(self.textFont)
    love.graphics.setColor(states.lineColor)

    if not self.hasStarted then
        local message = "Press A or D to move"
        love.graphics.print(message, const.WIDTH/2, const.HEIGHT - 50, 0, 1, 1, self.textFont:getWidth(message)/2)
    end

    -- interactable prompt
    local interactable = Interactables:getInteractableObject()
    if interactable then
        local promptText = interactable.promptMessage
        love.graphics.print(promptText, const.WIDTH/2, const.HEIGHT - 50, 0, 1, 1, self.textFont:getWidth(promptText)/2)
    end
end

function act:keypressed(key, isrepeat)
    if key == 'return' then
        Interactables:interact()
    end
end

return act