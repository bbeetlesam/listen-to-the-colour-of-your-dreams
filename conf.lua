function love.conf(t)
    t.version = "11.5"

    t.window.title = "Listen to The Colour of Your Dreams"
    t.window.icon = nil
    t.window.width = 1920/1.2
    t.window.height = 1200/1.2
    t.window.fullscreen = false
    t.window.resizable = true

    t.window.msaa = 0
    t.window.vsync = 1

    -- for debugging
    t.console = true -- set to false on final build
    t.window.display = 2 -- set to 1 on final build
    t.identity = nil
end