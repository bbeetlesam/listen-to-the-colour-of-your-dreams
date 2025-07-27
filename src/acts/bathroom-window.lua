local Camera = require("src.core.camera")
local Player = require("src.core.player")
local Interactables = require("src.interactables")
local const = require("src.helpers.const")
local utils = require("src.helpers.utils")
local states = require("src.states")
local sounds = require("src.core.sounds")
local dialogue = require("src.dialogues")

---@class BathroomWindow : Act
local act = {}

local img = {
    npc = love.graphics.newImage("assets/img/player-light-bold.png"),
}

local function getShapeOffsetCenter(shape)
    local minX, maxX, minY, maxY = math.huge, -math.huge, math.huge, -math.huge
    for _, b in ipairs(shape.blocks) do
        minX = math.min(minX, b[1])
        maxX = math.max(maxX, b[1])
        minY = math.min(minY, b[2])
        maxY = math.max(maxY, b[2])
    end
    local centerX = (minX + maxX + 1) / 2 * 32
    local centerY = (minY + maxY + 1) / 2 * 32
    return centerX, centerY
end

-- Define the puzzle area boundaries
local puzzleBounds = {
    left = 32*-50,
    right = 32*10,
    top = 32 * 80,
    bottom = 32 * 95,
}
-- Calculate the slope and intercept of the diagonal boundary line once
puzzleBounds.slope = (puzzleBounds.bottom - puzzleBounds.top) / (puzzleBounds.right - puzzleBounds.left)
puzzleBounds.intercept = puzzleBounds.top - puzzleBounds.slope * puzzleBounds.left

--- Converts a shape's local block coordinates to a table of global grid positions.
local function getGlobalBlockGridPositions(shape)
    local positions = {}
    for _, b in ipairs(shape.blocks) do
        -- The shape's (x,y) is its visual center, so we need to calculate the top-left of the bounding box first.
        local cx, cy = getShapeOffsetCenter(shape)
        local blockWorldX = shape.x - cx + b[1]*32
        local blockWorldY = shape.y - cy + b[2]*32

        local gridX = math.floor(blockWorldX / 32 + 0.5)
        local gridY = math.floor(blockWorldY / 32 + 0.5)
        table.insert(positions, {x = gridX, y = gridY})
    end
    return positions
end

--- Checks if all blocks of a shape are within the puzzle area.
local function isShapeInBounds(shape)
    local globalBlocks = getGlobalBlockGridPositions(shape)
    for _, blockPos in ipairs(globalBlocks) do
        local worldX = blockPos.x * 32
        local worldY = blockPos.y * 32

        if worldX < puzzleBounds.left or worldX >= puzzleBounds.right or worldY >= puzzleBounds.bottom then
            return false -- Outside simple rectangle bounds
        end
        -- Check against the diagonal slope line
        if worldY < (puzzleBounds.slope * worldX + puzzleBounds.intercept) then
            return false -- Above the slope
        end
    end
    return true
end

--- Checks if a shape is colliding with any other shapes in the list.
local function isCollidingWithOthers(heldShape, allShapes)
    local heldBlocks = getGlobalBlockGridPositions(heldShape)
    for _, otherShape in ipairs(allShapes) do
        if otherShape.id ~= heldShape.id then
            local otherBlocks = getGlobalBlockGridPositions(otherShape)
            for _, hb in ipairs(heldBlocks) do
                for _, ob in ipairs(otherBlocks) do
                    if hb.x == ob.x and hb.y == ob.y then return true end
                end
            end
        end
    end
    return false
end

function act:load()
    self.isPlaying = false

    Player:setPosition(32*115.5, 32*69.5) -- for debugging -- 32*115.5, 32*69.5 -- 32*(35.5 - 70), 32*(69.5 + 25)
    -- Player:setPlayable(true)
    -- Player:setSpeed(390)
    Player:clearWalls()
    Player:addWall(32*135, 32*69)
    Player:addWall(32*-50, 32*94)

    Player:clearHotPositions()
    Player:addHotPosition(32*35.5, 32*69.5, {
        right = "linear",
        left = "diagonal_inverted"
    })
    Player:addHotPosition(32*10.5, 32*94.5, {
        right = "diagonal_inverted",
        left = "linear"
    })

    Player:clearTriggers()
    -- initial monologue
    Player:addTrigger(32*115.5, 32*69.5, {
        mode = 'once',
        onUpdate = function(trigger, _, timer)
            if not trigger.d1 and timer >= 0 then
                dialogue:showTemporary(dialogue.act4[1], 3); trigger.d1 = true
            end
            if not trigger.d2 and timer >= 3 then
                dialogue:showTemporary(dialogue.act4[2], 3); trigger.d2 = true
                trigger.isActive = false
            end
        end
    })

    -- the wall
    Player:addTrigger(32*75.5, 32*69.5, {
        mode = 'once',
        onUpdate = function(trigger, _, timer)
            if not trigger.d and timer >= 0 then
                dialogue:showTemporary(dialogue.act4[3], 4); trigger.d = true
                trigger.isActive = false
            end
        end
    })

    -- found stairs
    Player:addTrigger(32*49.5, 32*69.5, {
        mode = 'once',
        onUpdate = function(trigger, _, timer)
            if not trigger.d and timer >= 0 then
                dialogue:showTemporary(dialogue.act4[4], 4); trigger.d = true
                trigger.isActive = false
            end
        end
    })

    -- found lady
    self.cameraPanTargetX = 32*-45.5
    Player:addTrigger(32*-30.5, 32*94.5, {
        mode = 'once',
        onUpdate = function(trigger, _, timer)
            if not trigger.started then
                Player:setPlayable(false); trigger.started = true
            end
            if not trigger.d5 and timer >= 1 then dialogue:showTemporary(dialogue.act4[5], 3); trigger.d5 = true
            elseif not trigger.d6 and timer >= 4 then dialogue:showTemporary(dialogue.act4[6], 2); trigger.d6 = true
            elseif not trigger.d7 and timer >= 6 then dialogue:showTemporary(dialogue.act4[7], 4); trigger.d7 = true
            elseif not trigger.d8 and timer >= 10 then dialogue:showTemporary(dialogue.act4[8], 4); trigger.d8 = true
            elseif not trigger.d9 and timer >= 14 then dialogue:showTemporary(dialogue.act4[9], 4); trigger.d9 = true
            elseif not trigger.d10 and timer >= 18 then dialogue:showTemporary(dialogue.act4[10], 4.5); trigger.d10 = true
            elseif not trigger.d11 and timer >= 22.5 then dialogue:showTemporary(dialogue.act4[11], 4.5); trigger.d11 = true
            elseif not trigger.d12 and timer >= 27 then dialogue:showTemporary(dialogue.act4[12], 2); trigger.d12 = true
            elseif not trigger.d13 and timer >= 29 then dialogue:showTemporary(dialogue.act4[13], 4); trigger.d13 = true
            elseif not trigger.d14 and timer >= 33 then dialogue:showTemporary(dialogue.act4[14], 4); trigger.d14 = true
            elseif not trigger.d15 and timer >= 37 then dialogue:showTemporary(dialogue.act4[15], 4.5); trigger.d15 = true
            elseif not trigger.d16 and timer >= 41.5 then dialogue:showTemporary(dialogue.act4[16], 4); trigger.d16 = true
            elseif not trigger.ended and timer >= 45.5 then trigger.ended = true
                trigger.isActive = false
                self.isPlaying = true
            end
        end
    })

    -- shapes
    self.heldStacko = nil
    local centerX = const.WIDTH/2
    local centerY = const.HEIGHT - 100
    self.stacko = {}

    self.isWin = false
    local shapeDefs = {
        {id = "A", blocks = {{0,0},{0,1},{0,2}}},
        {id = "B", blocks = {{0,0},{0,1},{0,2},{1,0}}},
        {id = "C", blocks = {{0,0},{1,0},{2,0}}},
        {id = "D", blocks = {{0,0},{0,1},{1,1}}},
        {id = "E", blocks = {{0,0},{1,0},{2,0},{0,1},{0,2}}},
        {id = "F", blocks = {{0,0},{1,0},{1,1},{2,1}}},
        {id = "G", blocks = {{0,0},{2,0},{0,1},{1,1},{2,1}}},
        {id = "H", blocks = {{0,0},{1,0},{2,0},{0,1},{1,1},{2,1}}},
    }

    local numShapes = #shapeDefs
    local spacing = 128
    local startX = centerX - (numShapes - 1) * spacing / 2

    for i, shapeDef in ipairs(shapeDefs) do
        local newShape = {
            id = shapeDef.id,
            blocks = shapeDef.blocks,
            x = startX + (i - 1) * spacing, y = centerY, held = false
        }
        newShape.lastValidX, newShape.lastValidY = newShape.x, newShape.y
        table.insert(self.stacko, newShape)
    end
end

function act:update(dt)
    Player:update(dt)

    local px, py = Player:getPosition()

    -- setting cam pos
    if self.isPlaying then
        -- after the dialogue, the camera pans to and stays at the puzzle area.
        local camX, _ = Camera:getPosition()
        local targetX = self.cameraPanTargetX

        local newCamX = camX
        if math.abs(camX - targetX) > 1 then
            local lerpFactor = 1 - math.exp(-dt * 3) -- speed
            newCamX = camX + (targetX - camX) * lerpFactor
        else
            newCamX = targetX
        end
        Camera:setPosition(newCamX, py - 32*3)
    else
        Camera:setPosition(math.max(math.min(px, 32*115.5), 32*-100), py - 32*3)
    end

    -- dragging stackos
    local mx, my = require("src.core.main-canvas"):getMouseCanvasPosition() -- from main-canvas
    if self.heldStacko and love.mouse.isDown(1) then
        self.heldStacko.x = mx - self.heldStacko.offsetX
        self.heldStacko.y = my - self.heldStacko.offsetY
    end
end

function act:draw()
    Camera:attach()
        utils.lines({32*35,32*70, 32*150,32*70}) -- ground line 1
        utils.lines({32*10,32*95, 32*-150,32*95}) -- ground line 2
        utils.lines({32*-50,32*95, 32*-50,32*80}) -- house

        -- stuff
        utils.draw.stairs(32*35, 32*70, 25, "left")
        utils.draw.stairs(32*-50, 32*85, 10, "right") -- house
        utils.draw.arrowSign(32*135, 32*70, 1)
        utils.draw.arrowSign(32*90, 32*70, -1)
        utils.draw.arrowSign(32*48, 32*70, -1)
        utils.draw.fences(32*(4 -15), 32*95, 15)
        utils.draw.bricks(32*(73-12), 32*70, 12, 8)

        -- Interactables:drawDebug()
        -- Player:drawWallDebug()
        -- Player:drawHotPositionDebug()
        -- Player:drawTriggerDebug()
        Player:draw()

        utils.draw.dashedLine({
            puzzleBounds.left, puzzleBounds.top,     -- top edge
            puzzleBounds.right, puzzleBounds.top,

            puzzleBounds.right, puzzleBounds.bottom, -- right edge
            puzzleBounds.left, puzzleBounds.bottom,  -- bottom edge

            puzzleBounds.left, puzzleBounds.bottom,  -- left edge (closing back)
            puzzleBounds.left, puzzleBounds.top,

            puzzleBounds.left, puzzleBounds.top,     -- diagonal line
            puzzleBounds.right, puzzleBounds.bottom
        }, 8, 6, 4, {1, 0.2, 0.2, 0.5})
    Camera:detach()

    -- draw stackos
    if self.isPlaying then
        love.graphics.setLineWidth(3)
        for _, shape in ipairs(self.stacko) do
            local cx, cy = getShapeOffsetCenter(shape)
            for _, b in ipairs(shape.blocks) do
                local bx = shape.x - cx + b[1]*32
                local by = shape.y - cy + b[2]*32
                love.graphics.setColor(0.5, 0.5, 0.5)
                love.graphics.rectangle("fill", bx, by, 32, 32)
                love.graphics.setColor(0, 0, 0)
                love.graphics.rectangle("line", bx, by, 32, 32)
            end
        end
        love.graphics.setColor(1, 1, 1)
    end
end

function act:mousepressed(x, y, button, _, _)
    if button ~= 1 then return end
    local mx, my = require("src.core.main-canvas"):getMouseCanvasPosition()

    -- Iterate backwards so we pick the top-most shape first
    for i = #self.stacko, 1, -1 do
        local shape = self.stacko[i]
        local cx, cy = getShapeOffsetCenter(shape)
        for _, b in ipairs(shape.blocks) do
            local bx = shape.x - cx + b[1]*32
            local by = shape.y - cy + b[2]*32
            if mx >= bx and mx <= bx + 32 and my >= by and my <= by + 32 then
                self.heldStacko = shape
                self.heldStacko.offsetX = mx - self.heldStacko.x
                self.heldStacko.offsetY = my - self.heldStacko.y
                -- Move the held shape to the end of the table so it's drawn on top
                table.remove(self.stacko, i)
                table.insert(self.stacko, self.heldStacko)
                -- Store its last valid position in case of an invalid drop
                self.heldStacko.lastValidX, self.heldStacko.lastValidY = self.heldStacko.x, self.heldStacko.y
                return
            end
        end
    end
end

function act:mousereleased(x, y, button, _, _)
    if button ~= 1 or not self.heldStacko then return end

    -- Fix the inconsistent snap by aligning the first block to the grid
    local cx, cy = getShapeOffsetCenter(self.heldStacko)
    local firstBlock = self.heldStacko.blocks[1]
    local firstBlockWorldX = self.heldStacko.x - cx + firstBlock[1]*32
    local firstBlockWorldY = self.heldStacko.y - cy + firstBlock[2]*32

    local targetBlockX = math.floor(firstBlockWorldX / 32 + 0.5) * 32
    local targetBlockY = math.floor(firstBlockWorldY / 32 + 0.5) * 32

    local deltaX = targetBlockX - firstBlockWorldX
    local deltaY = targetBlockY - firstBlockWorldY

    self.heldStacko.x = self.heldStacko.x + deltaX
    self.heldStacko.y = self.heldStacko.y + deltaY

    -- Check for collisions and bounds
    if isCollidingWithOthers(self.heldStacko, self.stacko) or not isShapeInBounds(self.heldStacko) then
        -- Invalid placement, revert to last known good position
        self.heldStacko.x, self.heldStacko.y = self.heldStacko.lastValidX, self.heldStacko.lastValidY
    else
        -- Valid placement, check for win condition
        self:checkWinCondition()
    end

    self.heldStacko = nil
end

function act:checkWinCondition()
    for _, shape in ipairs(self.stacko) do
        if not isShapeInBounds(shape) then
            self.isWin = false
            return -- At least one shape is not in the puzzle area
        end
    end
    -- If we get here, all shapes are in the puzzle area
    self.isWin = true
    print("YOU WIN!") -- For debugging
end

function act:keypressed(key, _) end

return act