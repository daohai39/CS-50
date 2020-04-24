PlayState = Class{ __includes = BaseState }

PIPE_SPEED = 60
PIPE_WIDTH = 70
PIPE_HEIGHT = 288

BIRD_WIDTH = 38
BIRD_HEIGHT = 24        

function PlayState:init( )
    self.bird = Bird()
    self.pipePairs = {}
    self.timer = 0
    self.score = 0
    self.lastY = -PIPE_HEIGHT + math.random(80) + 20
    self.timeSpawnPipeInterval = self:randomSpawnTimeInterval()
end

function PlayState:enter( params )
    self:load(params)
end 

function PlayState:save()
    return {
        ['bird'] = self.bird,
        ['pipePairs'] = self.pipePairs,
        ['timer'] = self.timer,
        ['score'] = self.score,
        ['lastY'] = self.lastY,
        ['timeSpawnInterval'] = self.timeSpawnPipeInterval
    }
end

function PlayState:load( gameState )
    if gameState == nil then
        return
    end
    self.bird = gameState['bird']
    self.pipePairs = gameState['pipePairs']
    self.timer = gameState['timer']
    self.score = gameState['score']
    self.lastY = gameState['lastY']
    self.timeSpawnPipeInterval = gameState['timeSpawnInterval']
end

function PlayState:update(dt) 
    if love.keyboard.wasPressed('p') then
        sounds['pause']:play()
        sounds['music']:pause()
        gStateMachine:change('pause', self:save())
        return
    end

    self.timer = self.timer + dt
    if self.timer > self.timeSpawnPipeInterval then
        local y = math.max(-PIPE_HEIGHT + 10, math.min(self.lastY + math.random( -20, 20 ), VIRTUAL_HEIGHT  - 90 - PIPE_HEIGHT))
        self.lastY = y

        table.insert(self.pipePairs, PipePair(y))
        self.timer = 0
        self.timeSpawnPipeInterval = self:randomSpawnTimeInterval()
    end    
    for k, pair in pairs(self.pipePairs) do
        if not pair.scored then
            if pair.x + PIPE_WIDTH < self.bird.x then
                self.score = self.score + 1
                pair.scored = true
                sounds['score']:play()
            end
        end
        
        pair:update(dt)
    end
    for k, pair in pairs(self.pipePairs) do 
        if pair.remove then
            table.remove(self.pipePairs, k)
        end
    end
    self.bird:update(dt)

    for k,pair in pairs(self.pipePairs) do
        for l, pipe in pairs(pair.pipes) do
            if self.bird:collides(pipe) then
                sounds['explosion']:play()
                sounds['hurt']:play()
                gStateMachine:change('score', {
                    score = self.score
                })
            end
        end
    end

    -- reset if we get to the ground
    if self.bird.y > VIRTUAL_HEIGHT - 15 then
        gStateMachine:change('score', {
            score = self.score
        })
    end
end

function PlayState:randomSpawnTimeInterval()
    return math.random( 2,4 ) + 0.5
end

function PlayState:render(  )
    for k, pair in pairs(self.pipePairs) do
        pair:render()
    end
    
    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(self.score), 8, 8)

    self.bird:render()
end