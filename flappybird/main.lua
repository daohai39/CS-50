push = require("push")
Class = require("class")

require 'Bird'
require 'Pipe'
require 'PipePair'
require 'Medal'
require 'Utils'

require 'StateMachine'
require 'states/BaseState'
require 'states/PlayState'
require 'states/PauseState'
require 'states/TitleScreenState'
require 'states/ScoreState'
require 'states/CountDownState'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

local background = love.graphics.newImage('images/background.png')
local backgroundScrollX = 0

local ground = love.graphics.newImage('images/ground.png')
local groundScrollX = 0

local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60

local BACKGROUND_LOOPING_POINT = 413
local GROUND_LOOPING_POINT = 514

local scrolling = true

function love.load(  )
    love.graphics.setDefaultFilter('nearest', 'nearest')
    --set up screen
    love.window.setTitle('Flappy Chick')
    
    smallFont = love.graphics.newFont('fonts/font.ttf', 8)
    mediumFont = love.graphics.newFont('fonts/flappy.ttf', 14)
    flappyFont = love.graphics.newFont('fonts/flappy.ttf', 28)
    hugeFont = love.graphics.newFont('fonts/flappy.ttf', 56)

    love.graphics.setFont(flappyFont)
    
    sounds = {
        ['jump'] = love.audio.newSource('sounds/jump.wav', 'static'),
        ['explosion'] = love.audio.newSource('sounds/explosion.wav', 'static'),
        ['hurt'] = love.audio.newSource('sounds/hurt.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['pause'] = love.audio.newSource('sounds/pause.wav', 'static'),

        ['music'] = love.audio.newSource('sounds/marios_way.mp3', 'static')        
    }

    sounds['music']:setLooping(true)
    sounds['music']:play()

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    -- init state machine
    gStateMachine = StateMachine {
        ['title'] = function () return TitleScreenState() end,
        ['play'] = function () return PlayState() end,
        ['pause'] = function () return PauseState() end,
        ['score'] = function () return ScoreState() end,
        ['countdown'] = function () return CountDownState() end
    }
    
    gStateMachine:change('title')

    -- init table keys pressed
    love.keyboard.keysPressed = {}
    love.mouse.buttonsPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
    if key == 'escape' then
        love.event.quit(0)
    end
end

function love.mousepressed(x, y, button)
    love.mouse.buttonsPressed[button] = true
end

function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function love.mouse.wasPressed( button )
    return love.mouse.buttonsPressed[button]
end

function love.update(dt) 
    backgroundScrollX = (backgroundScrollX + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT
    groundScrollX = (groundScrollX + GROUND_SCROLL_SPEED * dt) % VIRTUAL_WIDTH

    gStateMachine:update(dt)
    --reset keys pressed table
    love.keyboard.keysPressed = {}
    love.mouse.buttonsPressed = {}
end

function love.draw(  )
    push:start()

    -- draw background layer
    love.graphics.draw(background, -backgroundScrollX, 0)
    -- render pipePairs
    gStateMachine:render()    
    -- draw front ground layer
    love.graphics.draw(ground, -groundScrollX, VIRTUAL_HEIGHT - 16)

    push:finish()
end