---@class Interactables
local Interactables = {}

Interactables.objects = {}

function Interactables:clear()
    self.objects = {}
end

---@param options table
---{ type = 'callout'|'toggle', onInteract = function, initialState = boolean, w = number, h = number }
function Interactables:add(id, x, y, options)
    options = options or {}
    self.objects[id] = {
        id = id,
        x = x,
        y = y,
        w = options.w or 32,
        h = options.h or 32,
        type = options.type or 'callout',
        onInteract = options.onInteract,
        state = options.initialState or false,
        promptMessage = options.promptMessage
    }
end

--- finds the closest valid object the player can interact with
---@return table|nil the interactable object table, or nil if none is in range
function Interactables:getInteractableObject()
    local Player = require("src.core.player")
    local const = require("src.helpers.const")
    local px, py = Player:getPosition()
    local pDir = Player:getDirectionX()

    -- a check for 0 is good practice
    if pDir == 0 then return nil end

    -- calculate the position of the tile the player is facing
    local targetX = px + pDir * const.TILE_SIZE
    local targetY = py

    for _, obj in pairs(self.objects) do
        if targetX >= obj.x and targetX < (obj.x + obj.w) and
           targetY >= obj.y and targetY < (obj.y + obj.h) then
            return obj
        end
    end

    return nil
end

-- finds the closest valid object and triggers its interaction
function Interactables:interact()
    local closestObj = self:getInteractableObject()

    if closestObj then
        if closestObj.type == 'toggle' then
            closestObj.state = not closestObj.state
            if closestObj.onInteract then
                closestObj.onInteract(closestObj.state) -- pass the new state to the callback
            end
        elseif closestObj.type == 'callout' then
            if closestObj.onInteract then
                closestObj.onInteract()
            end
        end
    end
end

--- gets the current state of a toggleable interactable.
---@param id string The ID of the interactable.
---@return boolean|nil The state of the toggle, or nil if not found/not a toggle.
function Interactables:getState(id)
    if self.objects[id] and self.objects[id].type == 'toggle' then
        return self.objects[id].state
    end
    return nil
end

function Interactables:setPrompt(id, message)
    self.objects[id].promptMessage = message
end

-- for debugging
function Interactables:drawDebug()
    love.graphics.push("all")
    for _, obj in pairs(self.objects) do
        -- Draw the collider box
        love.graphics.setColor(0, 1, 0, 0.4)
        love.graphics.rectangle("fill", obj.x, obj.y, obj.w, obj.h)
        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", obj.x, obj.y, obj.w, obj.h)
    end
    love.graphics.pop()
end

return Interactables
