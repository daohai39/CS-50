Paddle = Class{}

local MINIMUM_WIDTH = 32

function Paddle:init(skin)
    self.x = VIRTUAL_WIDTH / 2 - 32
    self.y = VIRTUAL_HEIGHT - 32

    self.dx = 0

    self.skin = skin

    self.size = 2

    self.width = MINIMUM_WIDTH * self.size
    self.height = 16
end

function Paddle:shrinks()
    self.size = self.size - 1
    if self.size < 1 then
        self.size = 1 
    end

    self.width = MINIMUM_WIDTH * self.size
end

function Paddle:grows()
    self.size = self.size + 1
    if self.size > 3 then
        self.size = 3
    end

    self.width = MINIMUM_WIDTH * self.size
end

function Paddle:update(dt)
    if love.keyboard.isDown('left') then
        self.dx = -PADDLE_SPEED
    elseif love.keyboard.isDown('right') then
        self.dx = PADDLE_SPEED
    else
        self.dx = 0
    end

    if self.dx < 0 then
        self.x = math.max(0, self.x + self.dx * dt)
    else
        self.x = math.min(VIRTUAL_WIDTH - self.width, self.x + self.dx * dt)
    end    
end

function Paddle:render()
    love.graphics.draw(gTextures['main'], gFrames['paddles'][self.size + 4 * (self.skin - 1)], self.x, self.y)
end

