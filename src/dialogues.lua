local const = require("src.helpers.const")
local states = require("src.states")

local dialogues = {
    isShowing = false,
    message = "NULL",
    timer = 0,
    duration = 0,
    font = nil,

    act1 = {
        "The gigs was so fucking terrific.",
        "Uh, I'm so tired. I have to sleep a wink.",
    },
}

function dialogues.load()
    dialogues.font = love.graphics.newFont("assets/font/BalsamiqSansRegular.ttf", 25)
end

function dialogues.show(message)
    dialogues.isShowing = true
    dialogues.message = message or "NULL"
    dialogues.timer = 0
end

function dialogues.showTemporary(message, duration)
    dialogues.isShowing = true
    dialogues.message = message or "NULL"
    dialogues.duration = duration or 3
    dialogues.timer = dialogues.duration
end

function dialogues.hide()
    dialogues.isShowing = false
    dialogues.timer = 0
end

function dialogues.update(dt)
    if dialogues.timer > 0 then
        dialogues.timer = dialogues.timer - dt
        if dialogues.timer <= 0 then
            dialogues.hide()
        end
    end
end

function dialogues.draw()
    if dialogues.isShowing then
        love.graphics.push("all")
        love.graphics.setFont(dialogues.font)
        love.graphics.setColor(states.lineColor)
        love.graphics.printf(dialogues.message, 0, const.HEIGHT - 50, const.WIDTH, "center")
        love.graphics.pop()
    end
end

return dialogues