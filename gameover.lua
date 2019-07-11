local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
-- Initialize variables
local highscores = require( "highscoresUtils" )

local function gotoGame()
    composer.gotoScene( "game", { time=300, effect="crossFade" } )
end

local function gotoHighscores()
    composer.gotoScene( "highscores", { time=300, effect="crossFade" } )
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local background = display.newImageRect( sceneGroup, "background.png", 800, 1400 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	local title = display.newImageRect( sceneGroup, "gameover.png", 620, 181 )
	title.x = display.contentCenterX
	title.y = 100

	local actualScore = composer.getVariable("finalScore")

	local scoreMessage = display.newText( sceneGroup,
		"Hai totalizzato " .. actualScore .. " punti", 
		display.contentCenterX, display.contentCenterY - 40, native.systemFont, 44 )
	scoreMessage:setFillColor(1,1,0)

	-- Saving last game score --
	-- Load previous scores
    local scoresTable = highscores:loadScores()
	-- Delete old personal highscore and insert the last game score into the table, then reset it from composer
	-- !! only if game is just finished and actual score is greater than the last highscore or user never registered a score
	local lastHighscorePos = highscores:findLastHighscorePos( scoresTable )
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
	-- Save the updated scores
    highscores:saveScores( scoresTable )
	----
	-- Composing screen texts and buttons --
	local rankPosition = display.newText( sceneGroup,
		"#" .. highscores:findLastHighscorePos( scoresTable ) .. " in classifica", 
		display.contentCenterX, display.contentCenterY + 20, native.systemFont, 44 )
	rankPosition:setFillColor(1,1,0)
	transition.blink( rankPosition, { time=2000 } )


	local highscoresButton = display.newText( sceneGroup, "Highscores", display.contentCenterX, 850, native.systemFont, 44 )
    highscoresButton:setFillColor( 0.75, 0.78, 1 )
    highscoresButton:addEventListener( "tap", gotoHighscores )

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
		composer.removeScene( "gameover" )
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