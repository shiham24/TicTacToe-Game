-- welcome.lua

local composer = require("composer")
local widget = require("widget")
local scene = composer.newScene()

local centerX = display.contentCenterX
local centerY = display.contentCenterY

-- Load the custom fonts
local customFont = "SMARC___.TTF"
local buttonFont = "GrinchedRegular.otf"

local function loadCustomFont(fontName)
    local loadedFont = native.newFont(fontName)
    if not loadedFont then
        print("WARNING: Could not load font " .. fontName .. ". Using default font.")
        loadedFont = native.systemFontBold
    end
    return loadedFont
end

local customFont = loadCustomFont(customFont)
local buttonFont = loadCustomFont(buttonFont)

function scene:create(event)
    local sceneGroup = self.view

    -- Background
    local background = display.newImageRect("bg.png", display.actualContentWidth, display.actualContentHeight)
    background.x = centerX
    background.y = centerY
    sceneGroup:insert(background)

    -- Welcome text
    local welcomeText1 = display.newText({
        text = "Welcome to",
        x = centerX,
        y = centerY - 150,
        font = customFont,
        fontSize = 75
    })
    welcomeText1:setFillColor(0, 0, 0)
    sceneGroup:insert(welcomeText1)

    local welcomeText2 = display.newText({
        text = "Tic Tac Toe",
        x = centerX,
        y = centerY - 85,
        font = customFont,
        fontSize = 40
    })
    welcomeText2:setFillColor(0, 0, 0)
    sceneGroup:insert(welcomeText2)

    -- "Let's Play" button
    local function onPlayButtonRelease()
        composer.gotoScene("game", {effect = "fade", time = 800})
    end

    local playButton = widget.newButton({
        label = "Let's Play",
        onRelease = onPlayButtonRelease,
        emboss = false,
        shape = "roundedRect",
        width = 200,
        height = 50,
        cornerRadius = 10,
        fillColor = { default={0.1, 0.5, 0.8, 1}, over={0.1, 0.5, 0.8, 0.7} },
        labelColor = { default={1, 1, 1}, over={1, 1, 1, 0.5} },
        font = buttonFont,
        fontSize = 24
    })
    playButton.x = centerX
    playButton.y = centerY + 50
    sceneGroup:insert(playButton)

    -- "Exit Game" button
    local function onExitButtonRelease()
        if system.getInfo("platform") == "ios" then
            os.exit()
        else
            native.requestExit()
        end
    end

    local exitButton = widget.newButton({
        label = "Exit Game",
        onRelease = onExitButtonRelease,
        emboss = false,
        shape = "roundedRect",
        width = 200,
        height = 50,
        cornerRadius = 10,
        fillColor = { default={0.8, 0.1, 0.1, 1}, over={0.8, 0.1, 0.1, 0.7} },
        labelColor = { default={1, 1, 1}, over={1, 1, 1, 0.5} },
        font = buttonFont,
        fontSize = 24
    })
    exitButton.x = centerX
    exitButton.y = centerY + 120
    sceneGroup:insert(exitButton)

    -- Animation
    welcomeText1.alpha = 0
    welcomeText2.alpha = 0
    playButton.alpha = 0
    exitButton.alpha = 0

    transition.to(welcomeText1, {
        time = 1000,
        alpha = 1,
        onComplete = function()
            transition.to(welcomeText2, {
                time = 1000,
                alpha = 1,
                onComplete = function()
                    transition.to(playButton, {
                        time = 1000,
                        alpha = 1,
                        onComplete = function()
                            transition.to(exitButton, {time = 1000, alpha = 1})
                        end
                    })
                end
            })
        end
    })
end

scene:addEventListener("create", scene)
return scene
