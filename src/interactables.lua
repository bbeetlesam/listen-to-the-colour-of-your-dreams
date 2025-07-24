local Player = require("src.core.player")
local const = require("src.helpers.const")

---@class Interactables
local Interactables = {}

Interactables.objects = {}

function Interactables:clear()
    self.objects = {}
end

---@param options table
---{ type = 'callout'|'toggle', onInteract = function, initialState = boolean, w = number, h = number, detectionMethod = 'facing'|'on_spot' }
function Interactables:add(id, x, y, options)
    options = options or {}
    self.objects[id] = {
        id = id,
        x = x,
        y = y,
        w = options.w or 32,
        h = options.h or 32,
        detectionMethod = options.detectionMethod or 'facing',
        type = options.type or 'callout',
        onInteract = options.onInteract,
        state = options.initialState or false,
        promptMessage = options.promptMessage,
        isActive = options.isActive
    }
end

--- finds the closest valid object the player can interact with
---@return table|nil the interactable object table, or nil if none is in range
function Interactables:getInteractableObject()
    local px, py = Player:getPosition()
    local pDir = Player:getDirectionX()

    -- Calculate the facing position once, for 'facing' type interactables
    local targetX, targetY
    if pDir ~= 0 then
        targetX = px + pDir * const.TILE_SIZE
        targetY = py
    end

    for _, obj in pairs(self.objects) do
        if obj.isActive then
            if obj.detectionMethod == 'on_spot' then
                -- Point-based: Player must be ON the exact spot.
                if px == obj.x and py == obj.y then
                    return obj
                end
            else -- Default to 'facing'
                -- Area-based: Player must be FACING the object's area.
                if targetX and targetX >= obj.x and targetX < (obj.x + obj.w) and
                   targetY >= obj.y and targetY < (obj.y + obj.h) then
                    return obj
                end
            end
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

function Interactables:activate(id)
    if self.objects[id] then
        self.objects[id].isActive = true
    end
end

function Interactables:deactivate(id)
    if self.objects[id] then
        self.objects[id].isActive = false
    end
end

-- for debugging
function Interactables:drawDebug()
    love.graphics.push("all")
    for _, obj in pairs(self.objects) do
        if obj.isActive then
            if obj.detectionMethod == 'on_spot' then
                -- Draw a circle for point-based interactables
                love.graphics.setColor(0, 1, 1, 0.8)
                love.graphics.circle("fill", obj.x, obj.y, 8)
            else
                -- Draw the collider box for area-based interactables
                love.graphics.setColor(0, 1, 1, 0.4)
                love.graphics.rectangle("fill", obj.x, obj.y, obj.w, obj.h)
                love.graphics.setColor(0, 1, 1, 1)
                love.graphics.setLineWidth(1)
                love.graphics.rectangle("line", obj.x, obj.y, obj.w, obj.h)
            end
        end
    end
    love.graphics.pop()
end

return Interactables
