
local composer = require( "composer" )
local scene = composer.newScene()
composer.removeScene("game")

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
-- Initialize variables

local json = require( "json" )
 
local scoresTable = {}
 
local filePath = system.pathForFile( "scores.json", system.DocumentsDirectory )

-- this function manages names in the default scoresTable
local function getPlayerName( score )
	if ( score == 279 ) then
		return "Gianmarco"
	elseif ( score == 1000 ) then
		return "Marco"
	elseif ( score == 500 ) then
		return "Elisa"
	elseif ( score == 570 ) then
		return "Giovanna"
	elseif ( score == 190 ) then
		return "Andrea"
	elseif ( score == 3000 ) then
		return "Luca"
	elseif ( score == 4000 ) then
		return "Stefano"
	elseif ( score == 5000 ) then
		return "Dario"
	elseif ( score == 456 ) then
		return "Giulia"
	elseif ( score == 654 ) then
		return "Arianna"
	else
		return "Io"
	end
end

local function loadScores()
 
    local file = io.open( filePath, "r" )
 
    if file then
        local contents = file:read( "*a" )
        io.close( file )
        scoresTable = json.decode( contents )
    end
 
    if ( scoresTable == nil or #scoresTable == 0 ) then
        scoresTable = { 279, 1000, 500, 570, 190, 3000, 4000, 5000, 456, 654 } -- the default scoresTable
    end
end

local function saveScores()
 
    for i = #scoresTable, 11, -1 do
        table.remove( scoresTable, i )
    end
 
    local file = io.open( filePath, "w" )
 
    if file then
        file:write( json.encode( scoresTable ) )
        io.close( file )
    end
end

local function findLastHighscorePos()
	for i = 1, #scoresTable do
		if ( getPlayerName(scoresTable[i])=="Io" ) then
			return i
		end
	end
	return -1
end

local function gotoGame()
    composer.gotoScene( "game", { time=300, effect="crossFade" } )
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen --

	local background = display.newImageRect( sceneGroup, "background.png", 800, 1400 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	local title = display.newImageRect( sceneGroup, "highscore.png", 620, 181 )
	title.x = display.contentCenterX
	title.y = 100

	-- Loading high scores
	-- Load the previous scores
    loadScores()
	-- Delete old personal highscore, then insert the last game score into the table, then reset it from composer
	-- only if game is just finished and actual score is greater than last highscore or user never registered a score
	local actualScore = composer.getVariable("finalScore")
	local lastHighscorePos = findLastHighscorePos()
	if ( actualScore~=nil and lastHighscorePos~=-1 and actualScore>scoresTable[lastHighscorePos]) then
		table.remove( scoresTable, lastHighscorePos )
		table.insert( scoresTable, actualScore )
		composer.setVariable( "finalScore", 0 )
	elseif ( lastHighscorePos==-1 ) then -- user never registered a score
		table.insert( scoresTable, actualScore )
	end
	composer.setVariable("finalScore", 0)
	-- Sort the table entries from highest to lowest
    local function compare( a, b )
        return a > b
    end
    table.sort( scoresTable, compare )
	-- Save the scores
    saveScores()
	-- Showing the first 10 scores
	for i = 1, 10 do
        if ( scoresTable[i] ) then
            local yPos = 250 + ( i * 56 )
			--local playername = selectName(scoresTable[i])
			local rankNum = display.newText( sceneGroup, getPlayerName(scoresTable[i]) .. " - ", display.contentCenterX-50, yPos, native.systemFont, 36 )
            rankNum:setFillColor( 0.8 )
            rankNum.anchorX = 1
 
            local thisScore = display.newText( sceneGroup, scoresTable[i], display.contentCenterX-30, yPos, native.systemFont, 36 )
            thisScore.anchorX = 0
        end
    end

	local playButton = display.newText( sceneGroup, "Play", display.contentCenterX, 930, native.systemFont, 44 )
    playButton:setFillColor( 0.75, 0.78, 1 )
    playButton:addEventListener( "tap", gotoGame )

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		composer.removeScene( "highscores" )
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
