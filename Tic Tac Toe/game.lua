-- game.lua

local composer = require("composer")
local widget = require("widget")
local scene = composer.newScene()

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local cellSize = 100
local board = {}
local playerSymbol = ""
local computerSymbol = ""
local currentPlayer = ""
local gameOver = false
local chooseText, xButton, oButton, resetButton, backButton
local winnerText -- Declare winnerText at the top

local function getAvailableMoves()
    local moves = {}
    for i = 1, #board do
        if not board[i].label then
            table.insert(moves, i)
        end
    end
    return moves
end

local function evaluateBoard()
    for i = 0, 2 do
        if board[i * 3 + 1].label and board[i * 3 + 2].label and board[i * 3 + 3].label and
            board[i * 3 + 1].label.text == board[i * 3 + 2].label.text and board[i * 3 + 1].label.text == board[i * 3 + 3].label.text then
            return (board[i * 3 + 1].label.text == computerSymbol) and 1 or -1
        end
        if board[1 + i].label and board[4 + i].label and board[7 + i].label and
            board[1 + i].label.text == board[4 + i].label.text and board[1 + i].label.text == board[7 + i].label.text then
            return (board[1 + i].label.text == computerSymbol) and 1 or -1
        end
    end
    if board[1].label and board[5].label and board[9].label and
        board[1].label.text == board[5].label.text and board[1].label.text == board[9].label.text then
        return (board[1].label.text == computerSymbol) and 1 or -1
    end
    if board[3].label and board[5].label and board[7].label and
        board[3].label.text == board[5].label.text and board[3].label.text == board[7].label.text then
        return (board[3].label.text == computerSymbol) and 1 or -1
    end
    return 0
end

local function minimax(depth, isMaximizing)
    local score = evaluateBoard()
    if score == 1 then return score end
    if score == -1 then return score end
    if #getAvailableMoves() == 0 then return 0 end
    
    if isMaximizing then
        local bestScore = -math.huge
        for _, move in ipairs(getAvailableMoves()) do
            board[move].label = {text = computerSymbol}
            local score = minimax(depth + 1, false)
            board[move].label = nil
            bestScore = math.max(score, bestScore)
        end
        return bestScore
    else
        local bestScore = math.huge
        for _, move in ipairs(getAvailableMoves()) do
            board[move].label = {text = playerSymbol}
            local score = minimax(depth + 1, true)
            board[move].label = nil
            bestScore = math.min(score, bestScore)
        end
        return bestScore
    end
end

local function bestMove()
    local bestScore = -math.huge
    local move
    for _, availableMove in ipairs(getAvailableMoves()) do
        board[availableMove].label = {text = computerSymbol}
        local score = minimax(0, false)
        board[availableMove].label = nil
        if score > bestScore then
            bestScore = score
            move = availableMove
        end
    end
    return move
end

local function checkWinner(player)
    for i = 0, 2 do
        if board[i * 3 + 1].label and board[i * 3 + 2].label and board[i * 3 + 3].label and
            board[i * 3 + 1].label.text == board[i * 3 + 2].label.text and board[i * 3 + 1].label.text == board[i * 3 + 3].label.text then
            return true
        end
        if board[1 + i].label and board[4 + i].label and board[7 + i].label and
            board[1 + i].label.text == board[4 + i].label.text and board[1 + i].label.text == board[7 + i].label.text then
            return true
        end
    end
    if board[1].label and board[5].label and board[9].label and
        board[1].label.text == board[5].label.text and board[1].label.text == board[9].label.text then
        return true
    end
    if board[3].label and board[5].label and board[7].label and
        board[3].label.text == board[5].label.text and board[3].label.text == board[7].label.text then
        return true
    end
    return false
end

local function isBoardFull()
    for i = 1, #board do
        if not board[i].label then
            return false
        end
    end
    return true
end

local function makeComputerMove()
    if gameOver then return end
    local move = bestMove()
    if move then
        local cell = board[move]
        cell.label = display.newText(computerSymbol, cell.x, cell.y, "Roboto-Bold", 40)
        cell.label:setFillColor(0, 0, 0)
        if checkWinner(computerSymbol) then
            gameOver = true
            winnerText = display.newText(computerSymbol .. " Wins!", centerX, centerY - 250, "Roboto-Bold", 40)
        elseif isBoardFull() then
            gameOver = true
            winnerText = display.newText("It's a Draw!", centerX, centerY - 250, "Roboto-Bold", 40)
        else
            currentPlayer = playerSymbol
        end
    end
end

local function onCellTap(event)
    if gameOver or currentPlayer ~= playerSymbol then return end
    local cell = event.target
    if not cell.label then
        cell.label = display.newText(playerSymbol, cell.x, cell.y, "Roboto-Bold", 40)
        cell.label:setFillColor(0, 0, 0)
        if checkWinner(playerSymbol) then
            gameOver = true
            winnerText = display.newText(playerSymbol .. " Wins!", centerX, centerY - 250, "Roboto-Bold", 40)
        elseif isBoardFull() then
            gameOver = true
            winnerText = display.newText("It's a Draw!", centerX, centerY - 250, "Roboto-Bold", 40)
        else
            currentPlayer = computerSymbol
            timer.performWithDelay(500, makeComputerMove)
        end
    end
end

local function drawBoard()
    for i = 0, 2 do
        for j = 0, 2 do
            local rect = display.newRoundedRect(centerX + (j - 1) * cellSize, 300 + (i - 1) * cellSize, cellSize - 10, cellSize - 10, 10)
            rect.strokeWidth = 3
            rect:setFillColor(1, 1, 1)
            rect:setStrokeColor(0, 0, 0)
            rect.index = {i, j}
            rect:addEventListener("tap", onCellTap)
            board[i * 3 + j + 1] = rect
        end
    end
end

local function onChoice(event)
    playerSymbol = event.target:getLabel()
    computerSymbol = (playerSymbol == "X") and "O" or "X"
    currentPlayer = computerSymbol

    -- Remove the symbol selection UI
    display.remove(chooseText)
    display.remove(xButton)
    display.remove(oButton)

    -- Make the computer move first if it is the computer's turn
    if currentPlayer == computerSymbol then
        timer.performWithDelay(500, makeComputerMove)
    end

    -- Show the reset button after the player has made their choice
    resetButton.isVisible = true
end

local function resetGame()
    -- Reset game state variables
    gameOver = false
    playerSymbol = ""
    computerSymbol = ""
    currentPlayer = ""

    -- Remove any existing labels from the board
    for i = 1, #board do
        if board[i].label then
            board[i].label:removeSelf()
            board[i].label = nil
        end
    end

    -- Remove any existing winner text
    if winnerText then
        winnerText:removeSelf()
        winnerText = nil
    end

    -- Show the symbol selection UI again
    chooseText = display.newText(scene.view, "Choose X or O", centerX, centerY - 250, "Roboto-Bold", 24)

    xButton = widget.newButton({
        label = "X",
        labelColor = { default = { 1, 1, 1 }, over = { 0, 0, 0 } }, -- White text color (default and over)
        onRelease = onChoice,
        emboss = false,
        shape = "roundedRect",
        width = 55,
        height = 55,
        cornerRadius = 10,
        fillColor = {default = {1, 0.27058823529412, 0}, over = {1, 0.1, 0.7, 0.4}},
        
    })
    xButton.x = centerX - 50
    xButton.y = centerY - 175

    oButton = widget.newButton({
        label = "O",
        labelColor = { default = { 1, 1, 1 }, over = { 0, 0, 0 } }, -- White text color (default and over)
        onRelease = onChoice,
        emboss = false,
        shape = "roundedRect",
        width = 55,
        height = 55,
        cornerRadius = 10,
        fillColor = {default = {0, 0.54509803921569, 0.54509803921569}, over = {0.4, 0.1, 1, 0.4}},
    })
    oButton.x = centerX + 50
    oButton.y = centerY - 175

    scene.view:insert(xButton)
    scene.view:insert(oButton)

    resetButton.isVisible = false
end

local function backToMenu()
    -- Remove existing game elements
    display.remove(chooseText)
    display.remove(xButton)
    display.remove(oButton)
    display.remove(resetButton)
    display.remove(backButton)
    for i = 1, #board do
        if board[i].label then
            board[i].label:removeSelf()
        end
        board[i]:removeSelf()
    end
    board = {}
    if winnerText then
        winnerText:removeSelf()
    end

    -- Go to the welcome scene
    composer.gotoScene("welcome", {effect = "fade", time = 500})
end

local function destroyScene()
    -- Remove existing game elements
    display.remove(chooseText)
    display.remove(xButton)
    display.remove(oButton)
    display.remove(resetButton)
    display.remove(backButton)
    for i = 1, #board do
        if board[i].label then
            board[i].label:removeSelf()
        end
        board[i]:removeSelf()
    end
    board = {}
    if winnerText then
        winnerText:removeSelf()
    end
end

function scene:create(event)
    local sceneGroup = self.view
    chooseText = display.newText(sceneGroup, "Choose X or O", centerX, centerY - 250, "Roboto-Bold", 24)
    xButton = widget.newButton({
        label = "X",
        labelColor = { default = { 1, 1, 1 }, over = { 0, 0, 0 } }, -- White text color (default and over)
        onRelease = onChoice,
        emboss = false,
        shape = "roundedRect",
        width = 55,
        height = 55,
        cornerRadius = 10,
        fillColor = {default = {1, 0.27058823529412, 0}, over = {1, 0.1, 0.7, 0.4}},
        
    })
    xButton.x = centerX - 50
    xButton.y = centerY - 175
    oButton = widget.newButton({
        label = "O",
        labelColor = { default = { 1, 1, 1 }, over = { 0, 0, 0 } }, -- White text color (default and over)
        onRelease = onChoice,
        emboss = false,
        shape = "roundedRect",
        width = 55,
        height = 55,
        cornerRadius = 10,
        fillColor = {default = {0, 0.54509803921569, 0.54509803921569}, over = {0.4, 0.1, 1, 0.4}},
        
    })
    oButton.x = centerX + 50
    oButton.y = centerY - 175
    sceneGroup:insert(xButton)
    sceneGroup:insert(oButton)
    resetButton = widget.newButton({
        label = "Reset Game",
        labelColor = { default = { 1, 1, 1 }, over = { 0, 0, 0 } },
        onRelease = resetGame,
        emboss = false,
        shape = "roundedRect",
        width = 150,
        height = 50,
        cornerRadius = 10,
        fillColor = { default = { 0.85490196078431, 0.43921568627451, 0.83921568627451 }, over = { 0.1, 1, 0.7, 0.4 } },
        font = "GrinchedRegular.otf",
        fontSize = 24 -- Add this line to set the font size
    })
    
    resetButton.x = centerX
    resetButton.y = centerY + 250
    resetButton.isVisible = false
    sceneGroup:insert(resetButton)
    
    backButton = widget.newButton({
        label = "Back to Menu",
        labelColor = { default = { 1, 1, 1 }, over = { 0, 0, 0 } },
        onRelease = backToMenu,
        emboss = false,
        shape = "roundedRect",
        width = 150,
        height = 50,
        cornerRadius = 10,
        fillColor = { default = { 0.25490196078431, 0.41176470588235, 0.88235294117647 }, over = { 1, 0.1, 0.7, 0.4 } },
        font = "GrinchedRegular.otf",
        fontSize = 24 -- Add this line to set the font size
    })
    backButton.x = centerX
    backButton.y = centerY + 310
    sceneGroup:insert(backButton)
    drawBoard()
end

scene:addEventListener("create", scene)
scene:addEventListener("destroy", destroyScene)
return scene
