local const = require("src.helpers.const")
local states = require("src.states")

local dialogues = {
    isShowing = false,
    message = "NULL",
    timer = 0,
    duration = 0,
    font = nil,

    act1 = {
        "Bloody hell, the gigs was so fucking terrific.",
        "Ugh, I'm so tired. I haven't slept a wink.",
        "Feels like my mind is on the blink right now.",
        "What the fucking fuck man?",
        "Mate, I didn't even puff, I swear.",
        "Weird vibes, man... might be worth takin' a peek outside.",
    },
    act2 = {
        "Jesus Mother Mary...",
        "Bet it's that trippy bollocks Bob brought over yesterday. Should've known better.",
        "Holy Walrus... Stairway to Hell?",
        "Oh man, I'm definitely on something... cheers, Bob...",
        "How much bloody longer 'til I hit the bottom, huh?",
    },
    act3 = {
        "Bloody hell, what the fuck is that crowd?",
        "Oh no... they're comin' straight at me!",
        "Holy shite, a fucking rock?",
        "You must be kidding me mate",
        "Mate, you're as slow as a fucking nail. That was bloody close!",
        "Can't go there? Fuck. I should go back, innit?",
        "Let's hide on that fucking booth!"
    },
}

function dialogues:load()
    self.font = love.graphics.newFont("assets/font/BalsamiqSansRegular.ttf", 25)
    self.promptFont = love.graphics.newFont("assets/font/BalsamiqSansRegular.ttf", 20)
end

function dialogues:show(message)
    self.isShowing = true
    self.message = message or "NULL"
    self.timer = 0
end

function dialogues:showTemporary(message, duration)
    self.isShowing = true
    self.message = message or "NULL"
    self.duration = duration or 3
    self.timer = self.duration
end

function dialogues:hide()
    self.isShowing = false
    self.timer = 0
end

function dialogues:update(dt)
    if self.timer > 0 then
        self.timer = self.timer - dt
        if self.timer <= 0 then
            self:hide()
        end
    end
end

function dialogues:draw()
    if self.isShowing then
        love.graphics.push("all")
        love.graphics.setFont(self.font)
        love.graphics.setColor(states.lineColor)
        love.graphics.printf(self.message, 0, const.HEIGHT - 50, const.WIDTH, "center")
        love.graphics.pop()
    end
end

return dialogues