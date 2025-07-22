local mainCanvas = require("src.core.main-canvas")
local states = require("src.states")
local Acts = require("src.acts")

function love.load()
    mainCanvas:load()
end

function love.update(dt)
    mainCanvas:update(dt)
    states.update(dt)
end

function love.draw()
    mainCanvas:draw()
end

function love.keypressed(key, _, isrepeat)
    if key == "escape" then
        love.event.quit()
    elseif key == "f11" then
        states.fullscreen = not states.fullscreen
        love.window.setFullscreen(states.fullscreen)
    end
    Acts:keypressed(key, isrepeat)
end

function love.resize(w, h)
    mainCanvas:resize(w, h)
end