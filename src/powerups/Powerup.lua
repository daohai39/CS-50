Powerup = Class{}

function Powerup:init( x, y )
    self.x = x
    self.y = y

    self.width = 16
    self.height = 16

    self.dy = 20
    self.inPlay = true
end

function Powerup:update(dt)
    self.y = self.y + self.dy * dt
end

function Powerup:collides(paddle)
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    elseif self.y > paddle.y + paddle.width or paddle.y > self.y + self.height then
        return false
    end
    return true
end

function Powerup:useAbility()
    self.inPlay = false
end

function Powerup:render()
    if not self.inPlay then
        return
    end
    love.graphics.draw(gTextures['main'], gFrames['power-ups'][9], self.x, self.y)
end