local mainCanvas = require("src.core.main-canvas")
local states = require("src.states")

function love.load()
    mainCanvas:load()
end

function love.update(dt)
    mainCanvas:update(dt)
end

function love.draw()
    mainCanvas:draw()
end

function love.keypressed(key, _, _)
    if key == "escape" then
        love.event.quit()
    elseif key == "f11" then
        states.fullscreen = not states.fullscreen
        love.window.setFullscreen(states.fullscreen)
    end
end

function love.resize(w, h)
    mainCanvas:resize(w, h)
end