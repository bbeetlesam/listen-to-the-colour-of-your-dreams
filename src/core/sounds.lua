local sounds = {}

function sounds.load()
    sounds.doorOpen = love.audio.newSource("assets/sfx/door-open.ogg", "static")
    sounds.doorClose = love.audio.newSource("assets/sfx/door-closed.ogg", "static")
    sounds.rockHit = love.audio.newSource("assets/sfx/hit-rock.ogg", "static")
    sounds.rockBoom = love.audio.newSource("assets/sfx/boom-rock.ogg", "static")
    sounds.crowd = love.audio.newSource("assets/sfx/crowd-screams.ogg", "stream")
end

return sounds