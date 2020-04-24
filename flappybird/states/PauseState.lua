PauseState = Class { __includes = BaseState }

local PAUSE_IMAGE = love.graphics.newImage('images/pause-button.png')

function PauseState:enter( params )
    self.pauseParams = params
end

function PauseState:update( dt )
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown', self.pauseParams)
    elseif love.mouse.wasPressed(1) then
        gStateMachine:change('countdown', self.pauseParams)
    end
end

function PauseState:render()
    love.graphics.draw(PAUSE_IMAGE, VIRTUAL_WIDTH / 2 - 20, VIRTUAL_HEIGHT / 2 - 30, rotation, getImageScaleForNewDimension(PAUSE_IMAGE, 40, 40))

    love.graphics.setFont(mediumFont)
    love.graphics.printf("Press Enter to continue..", 0, 200, VIRTUAL_WIDTH, 'center')
end