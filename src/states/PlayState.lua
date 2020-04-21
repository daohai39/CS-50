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
    self.recoverPoints = 800

    self.ball.dx = math.random(-200, 200)
    self.ball.dy = math.random(-50, -60)
end

function PlayState:spawnNewBallAt(x, y)
    local tempBall = Ball(self.ball.skin)
    tempBall.x = x
    tempBall.y = y
    tempBall.dx = math.random(-200, 200)
    tempBall.dy = math.random(-50, -60)
    return tempBall
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

function PlayState:checkCollideWithBrickAndMoveBall(ball, brick)
    if ball.x + 2 < brick.x and ball.dx > 0 then
        -- trigger left-side collision
        ball.dx = -ball.dx
        ball.x = brick.x - ball.width
    elseif ball.x + 6  > brick.x + brick.width and ball.dx < 0 then
        -- trigger right-side collision
        ball.dx = -ball.dx
        ball.x = brick.x + brick.width
    elseif ball.y < brick.y then
        -- trigger top-side collision
        ball.dy = -ball.dy
        ball.y = brick.y - ball.height
    else
        -- trigger bottom-side collisiion
        ball.dy = -ball.dy
        ball.y = brick.y + brick.height
    end
    -- slightly scale the y velocity to speed up the game, capping at +- 150
    if math.abs(ball.dy) < 150 then
        ball.dy = ball.dy * BALL_SPEED_SCALING
    end
end

function PlayState:checkAndHandleCollideWithBrick(ball, brick)
    self.score = self.score + (brick.tier * 200 + brick.color * 25)

    brick:hit()
     -- if we have enough points, recover a point of health
     if self.score > self.recoverPoints then
        -- can't go above 3 health
        self.health = math.min(3, self.health + 1)

        -- multiply recover points by 2
        self.recoverPoints = math.min(100000, self.recoverPoints * 2)

        -- play recover sound effect
        gSounds['recover']:play()

        -- grow paddle

        self.paddle:grows()
    end

    if self.bricksTillPowerup > 0 then
        self.bricksTillPowerup = self.bricksTillPowerup - 1
    elseif self.bricksTillPowerup <= 0 then
        self.bricksTillPowerup = math.random( 10, 20 )
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

    self:checkCollideWithBrickAndMoveBall(ball, brick)
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
            self.powerUps[i]:useAbility()
            table.insert( self.extraBalls, self:spawnNewBallAt(self.paddle.x + self.paddle.width / 2, self.paddle.y - 8) )
            table.insert( self.extraBalls, self:spawnNewBallAt(self.paddle.x + self.paddle.width / 2, self.paddle.y - 8) )
        end
    end
    

    if self.ball:collides(self.paddle) then
       self:onBallCollideWithPaddle(self.ball)
    end

    for i = 1, #self.extraBalls do
        if not self.extraBalls[i].inPlay then
            ::continue::
        end
        if self.extraBalls[i]:collides(self.paddle) then
            self:onBallCollideWithPaddle(self.extraBalls[i])
        end
    end

    for k, brick in pairs(self.bricks) do
        if brick.inPlay and self.ball:collides(brick) then
            self:checkAndHandleCollideWithBrick(self.ball, brick)
        end
        for i = 1, #self.extraBalls do
            if not self.extraBalls[i].inPlay then
                ::continue::
            end
            if brick.inPlay and self.extraBalls[i]:collides(brick) then
                self:checkAndHandleCollideWithBrick(self.extraBalls[i], brick)
            end
        end
    end

    local removeIndexes = {}

    for i = 1, #self.extraBalls do
        if self.extraBalls[i].y >= VIRTUAL_HEIGHT then
            table.insert(removeIndexes, i)
        end
    end

    for i = 1, #removeIndexes do
        table.remove( self.extraBalls, removeIndexes[i] )
    end

    if self.ball.y >= VIRTUAL_HEIGHT then 
        if #self.extraBalls > 0 then
            local ballIndex = math.random( 1, #self.extraBalls )
            self.ball = self.extraBalls[ballIndex]
            table.remove(self.extraBalls, ballIndex)
        else
            self.health = self.health - 1
            self.paddle:shrinks()
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