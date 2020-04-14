Brick = Class{}

function Brick:init( x, y )
    self.x = x
    self.y = y

    self.tier = 0
    self.color = 1
    
    self.width = 32
    self.height = 16

    self.inPlay = true
end

function Brick:hit()
    gSounds['brick-hit-2']:play()
    self.inPlay = false
end

function Brick:render()
    if not self.inPlay then
        return
    end
    
    love.graphics.draw(gTextures['main'], gFrames['bricks'][1 + ((self.color - 1) * 4) + self.tier], self.x, self.y)
end
