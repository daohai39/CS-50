PipePair = Class {}

local GAP_HEIGHT_MAX = 110
local GAP_HEIGHT_MIN = 90

function PipePair:init( y )
    self.x = VIRTUAL_WIDTH + 32
    self.y = y

    self.pipes = {
        ['upper'] = Pipe('top', self.y),
        ['lower'] = Pipe('bottom', self.y + self:gapHeightRandomize() + PIPE_HEIGHT)
    }

    self.remove = false
    self.scored = false
end

function PipePair:gapHeightRandomize(  )
    return math.random( GAP_HEIGHT_MIN,GAP_HEIGHT_MAX )
end

function PipePair:update( dt )
    if self.x > -PIPE_WIDTH then
        self.x = self.x - PIPE_SPEED * dt
        self.pipes['upper'].x = self.x
        self.pipes['lower'].x = self.x
    else 
        self.remove = true
    end
end

function PipePair:render(  )
    for k, pipe in pairs(self.pipes) do
        pipe:render()
    end
end
