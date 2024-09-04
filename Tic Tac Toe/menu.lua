local composer = require("composer")
local scene = composer.newScene()

function scene:create(event)
    local sceneGroup = self.view

    -- Display title
    local title = display.newText(sceneGroup, "Tic Tac Toe", display.contentCenterX, display.contentCenterY - 100, native.systemFontBold, 32)
    title:setFillColor(0)

    -- Display play button
    local playButton = display.newText(sceneGroup, "Play Game", display.contentCenterX, display.contentCenterY, native.systemFontBold, 24)
    playButton:setFillColor(0, 0.5, 1)
    
    playButton:addEventListener("tap", function()
        composer.gotoScene("game")
    end)
end

function scene:show(event)
    if (event.phase == "did") then
        -- Code to run when the scene is now on screen
    end
end

function scene:hide(event)
    if (event.phase == "will") then
        -- Code to run when the scene is on screen (but is about to go off screen)
    end
end

function scene:destroy(event)
    -- Code to run prior to the removal of scene's view
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
