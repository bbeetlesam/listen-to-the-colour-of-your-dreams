local Act = require("src.acts")
local const = require("src.helpers.const")

local states = {}

states.fullscreen = love.window.getFullscreen()
states.currentAct = Act:getAct()
states.playCount = 1
states.bgColor = const.BROKEN_WHITE
states.lineColor = const.BLACK

-- update states
states.update = function(dt)
    states.currentAct = Act:getAct()
end

return states