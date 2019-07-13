local composer = require( "composer" )
local scene = composer.newScene()

local highscores = require( "highscoresUtils" )

local playerUtils = require( "playerUtils" )

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
-- Scene functions

local function gotoMenu()
    composer.gotoScene( "menu", { time=300, effect="crossFade" } )
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

	local title = display.newImageRect( sceneGroup, "highscores.png", 620, 181 )
	title.x = display.contentCenterX
	title.y = 100

	-- Loading high scores --
	-- Load previous scores
    local scoresTable = highscores:loadScores()
	scoresTable = highscores:sortScores( scoresTable )
	-- Showing the first 10 scores
	local personalPlayerName = playerUtils:getPlayerName(  )
	for i = 1, 10 do
        if ( scoresTable[i] ) then
			local playerName = highscores:getPlayerName(scoresTable[i])
            local yPos = 250 + ( i * 56 )
			local rankPlayer = display.newText( sceneGroup, playerName .. " - ", display.contentCenterX-50, yPos, native.systemFont, 36 )
            rankPlayer:setFillColor( 0.8 )
            rankPlayer.anchorX = 1
 
            local playerScore = display.newText( sceneGroup, scoresTable[i], display.contentCenterX-30, yPos, native.systemFont, 36 )
            playerScore.anchorX = 0

			if ( playerName == personalPlayerName ) then
				rankPlayer:setFillColor(1,1,0)
				playerScore:setFillColor(1,1,0)
				transition.blink( rankPlayer, { time=2000 } )
				transition.blink( playerScore, { time=2000 } )
			end
        end
    end
	-----
	-- Composing screen button --
	local menuButton = display.newText( sceneGroup, "Menu", display.contentCenterX, 930, native.systemFont, 44 )
    menuButton:setFillColor( 0.75, 0.78, 1 )
    menuButton:addEventListener( "tap", gotoMenu )

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
