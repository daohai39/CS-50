PlayState = Class{__includes = BaseState}

local BALL_SPEED_SCALING = 1.02

function PlayState:init( )
    self.paused = false
    self.powerUps = {}
    self.extraBalls = {}
end

function PlayState:enter(params)
    self.ball = params.ball
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.score = params.score
    self.health = params.health
    self.level = params.level
    self.highScores = params.highScores
    self.bricksTillPowerup = 0
    
    self.ball.dx = math.random(-400, 400)
    self.ball.dy = math.random(-50, -60)
end

function PlayState:onBallCollideWithPaddle(ball)
    -- raise the ball above the paddle in case it go below it
    -- then reverse dy
    ball.y = self.paddle.y - ball.height
    ball.dy = -ball.dy

    if ball.x < self.paddle.x + self.paddle.width / 2 and self.paddle.dx < 0 then           -- left side of paddle while moving left
        ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
    elseif ball.x > self.paddle.x + self.paddle.width / 2 and self.paddle.dx > 0 then      -- right side of paddle while moving right
        ball.dx = 50 + (8 * math.abs( self.paddle.x + self.paddle.width / 2 - ball.x))
    end

    gSounds['paddle-hit']:play()
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
 
    for i = 1, #self.powerUps do
        self.powerUps[i]:update(dt)
    end

    for i = 1, #self.extraBalls do
        self.extraBalls[i]:update(dt)
    end

    for i = 1, #self.powerUps do
        if (self.powerUps[i]:collides(self.paddle)) and self.powerUps[i].inPlay then
            gSounds['select']:play()
            self.powerUps[i]:earned()
            local ball1 = Ball(self.ball.skin)
            local ball2 = Ball(self.ball.skin)
            ball1.x = self.paddle.x + self.paddle.width / 2
            ball1.y = self.paddle.y - ball1.height
            ball1.dx = math.random(-400, 400)
            ball1.dy = math.random(-50, -60)
            ball2.x = self.paddle.x + self.paddle.width / 2
            ball2.y = self.paddle.y - ball2.height
            ball2.dx = math.random(-400, 400)
            ball2.dy = math.random(-50, -60)
            self.extraBalls[#self.extraBalls + 1] = ball1
            self.extraBalls[#self.extraBalls + 1] = ball2
        end
    end
    

    if self.ball:collides(self.paddle) then
       self:onBallCollideWithPaddle(self.ball)
    end

    for i = 1, #self.extraBalls do
        if not self.extraBalls.inPlay then
            ::continue::
        end
        if self.extraBalls[i]:collides(self.paddle) then
            self:onBallCollideWithPaddle(self.extraBalls[i])
        end
    end

    for k, brick in pairs(self.bricks) do
        if brick.inPlay and self.ball:collides(brick) then
            --update score
            self.score = self.score + (brick.tier * 200 + brick.color * 25)

            brick:hit()
            if self.bricksTillPowerup > 0 then
                self.bricksTillPowerup = self.bricksTillPowerup - 1
            elseif self.bricksTillPowerup <= 0 then
                self.bricksTillPowerup = math.random( 2, 5 )
                self.powerUps[#self.powerUps + 1] = Powerup(brick.x + brick.width / 2, brick.y + brick.height + 8)
                gSounds['recover']:play()
            end

            if self:checkVictory() then
                gStateMachine:change('victory', {
                    level = self.level,
                    paddle = self.paddle,
                    health = self.health,
                    score = self.score,
                    ball = self.ball,
                    highScores = self.highScores
                })
            end

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
                self.ball.y = brick.y + brick.height
            end
            -- slightly scale the y velocity to speed up the game, capping at +- 150
            if math.abs(self.ball.dy) < 150 then
                self.ball.dy = self.ball.dy * BALL_SPEED_SCALING
            end
        end
    end

    if self.ball.y >= VIRTUAL_HEIGHT then 
        self.health = self.health - 1
        gSounds['hurt']:play()
        if self.health > 0 then
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                level = self.level,
                score = self.score,
                health = self.health,
                highScores = self.highScores
            })
        else
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        end
    end

    -- for rendering particle
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
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

    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    for i = 1, #self.powerUps do
        self.powerUps[i]:render()
    end

    for i = 1, #self.extraBalls do
        self.extraBalls[i]:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end
    end
    return true
end