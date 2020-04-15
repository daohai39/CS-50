PlayState = Class{__includes = BaseState}

local BALL_SPEED_SCALING = 1.02

function PlayState:init( )
    self.paused = false
end

function PlayState:enter(params)
    self.ball = params.ball
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.score = params.score
    self.health = params.health

    self.ball.dx = math.random(-400, 400)
    self.ball.dy = math.random(-50, -60)
end

function PlayState:update(dt)
    if self.paused then 
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
    end

    self.paddle:update(dt)
    self.ball:update(dt)

    if self.ball:collides(self.paddle) then
        -- raise the ball above the paddle in case it go below it
        -- then reverse dy
        self.ball.y = self.paddle.y - 8
        self.ball.dy = -self.ball.dy

        -- left side of paddle while moving left
        if self.ball.x < self.paddle.x + self.paddle.width / 2 and self.ball.dx < 0 then
            self.ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.ball.x))
        end

        -- right side of paddle while moving right
        if self.ball.x > self.paddle.x + self.paddle.width / 2 and self.ball.dx > 0 then
            self.ball.dx = 50 + (8 * math.abs( self.paddle.x + self.paddle.width / 2 - self.ball.x))
        end

        gSounds['paddle-hit']:play()
    end

    for k, brick in pairs(self.bricks) do
        if brick.inPlay and self.ball:collides(brick) then
            --update score
            self.score = self.score + (brick.tier * 200 + brick.color * 25)

            if self.ball.x + 2 < brick.x and self.ball.dx > 0 then
                -- trigger left-side collision
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x - self.ball.width
            elseif self.ball.x + 6  > brick.x + brick.width and self.ball.x < 0 then
                -- trigger right-side collision
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x + brick.width
            elseif self.ball.y < brick.y then
                -- trigger top-side collision
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y - self.ball.height
            else
                -- trigger bottom-side collisiion
                self.ball.dy = -self.ball.dy
                self.ball.dy = brick.y + brick.height
            end
            self.ball.dy = self.ball.dy * BALL_SPEED_SCALING

            brick:hit()
        end
    end

    if self.ball.y >= VIRTUAL_HEIGHT then 
        self.health = self.health - 1
        gSounds['hurt']:play()
        if self.health > 0 then
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                score = self.score,
                health = self.health
            })
        else
            gStateMachine:change('game-over', {
                score = self.score
            })
        end
    end
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    self.paddle:render()
    self.ball:render()
    
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end