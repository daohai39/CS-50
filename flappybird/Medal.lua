Medal = Class {}

local BRONZE_MEDAL = love.graphics.newImage('images/bronze.png')
local SLIVER_MEDAL = love.graphics.newImage('images/sliver.png')
local GOLD_MEDAL = love.graphics.newImage('images/gold.png')

local rotation = 0

function Medal:init( medal )
    if medal == 'bronze' then
        self.image = BRONZE_MEDAL
    elseif medal == 'sliver' then
        self.image = SLIVER_MEDAL
    elseif medal == 'gold' then
        self.image = GOLD_MEDAL
    end
end

function Medal:render()
    love.graphics.draw(self.image, VIRTUAL_WIDTH / 2 - 20, VIRTUAL_HEIGHT / 2 - 30, rotation, getImageScaleForNewDimension(self.image, 40, 40))
end