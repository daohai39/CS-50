ScoreState = Class { __includes = BaseState }

local BRONZE_MIN_SCORE = 0
local SLIVE_MIN_SCORE = 3
local GOLD_MIN_SCORE = 5

function ScoreState:enter( params )
    self.score = params.score
    if self.score >= BRONZE_MIN_SCORE and  self.score < SLIVE_MIN_SCORE then
        self.medal = Medal('bronze')
    elseif self.score >= SLIVE_MIN_SCORE and self.score < GOLD_MIN_SCORE then
        self.medal = Medal('sliver')
    elseif self.score >= GOLD_MIN_SCORE then
        self.medal = Medal('gold')
    end
end

function ScoreState:update( dt )
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render(  )
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Oof! You lost!', 0, 64, VIRTUAL_WIDTH, 'center')
    
    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')

    love.graphics.printf('Press Enter To Play Again!', 0, 160, VIRTUAL_WIDTH, 'center')

    self.medal:render()
end