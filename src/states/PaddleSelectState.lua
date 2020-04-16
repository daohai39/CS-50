PaddleSelectState = Class{__includes = BaseState}

function PaddleSelectState:init()
    self.currentPaddle = 1
end

function PaddleSelectState:enter( params )
    self.highScores = params.highScores
end

function PaddleSelectState:update( dt ) 
    if love.keyboard.wasPressed('left') then
        if self.currentPaddle > 1 then
            gSounds['select']:play()
            self.currentPaddle = self.currentPaddle - 1
        else
            gSounds['no-select']:play()
        end
    elseif love.keyboard.wasPressed('right') then
        if self.currentPaddle == 4 then
            gSounds['no-select']:play()
        else
            gSounds['select']:play()
            self.currentPaddle = self.currentPaddle + 1
        end
    end

    if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
        gSounds['confirm']:play()
        gStateMachine:change('serve', {
            paddle = Paddle(self.currentPaddle),
            bricks = LevelMaker.createMap(1),
            level = 1,
            highScores = self.highScores,
            score = 0,
            health = 3
        })
    end

    if love.keyboard.wasPressed('escape') then
        love.envent.quit()
    end
end

function PaddleSelectState:render( )
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf("Select your paddle with left and right!", 0, VIRTUAL_HEIGHT / 4, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(gFonts['small'])
    love.graphics.printf("Press Enter to confirm", 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')

    if self.currentPaddle == 1 then
        love.graphics.setColor(40 / 255, 40 / 255, 40 / 255, 128 / 255)
    end

    love.graphics.draw(gTextures['arrows'], gFrames['arrows'][1], VIRTUAL_WIDTH / 4 - 24, VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)

    love.graphics.setColor(255 / 255, 255 / 255, 255 / 255, 255 / 255)

    if self.currentPaddle == 4 then
        love.graphics.setColor(40 / 255, 40 / 255, 40 / 255, 40 / 255)
    end

    love.graphics.draw(gTextures['arrows'], gFrames['arrows'][2], VIRTUAL_WIDTH - VIRTUAL_WIDTH / 4, VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)

    love.graphics.setColor(255 / 255, 255 / 255, 255 / 255, 255 / 255)
    
    love.graphics.draw(gTextures['main'], gFrames['paddles'][2 + 4 * (self.currentPaddle - 1)], VIRTUAL_WIDTH / 2 - 32, VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)
end