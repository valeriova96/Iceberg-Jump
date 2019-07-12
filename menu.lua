-- Scene and libraries for menu scene --
local composer = require( "composer" )
local scene = composer.newScene()

local audioUtils = require( "audioUtils" )

-- -----------------------------------------------------------------------------------
-- Scene functions
-- -----------------------------------------------------------------------------------

local function gotoGame()
	composer.gotoScene( "game", { time=300, effect="crossFade" } )
end

local function gotoHighScores()
	composer.gotoScene( "highscores", { time=300, effect="crossFade" } )
end

local function gotoSettings()
	composer.gotoScene( "settings", { time=300, effect="crossFade" } )
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

	local title = display.newImageRect( sceneGroup, "title.png", 620, 181 )
	title.x = display.contentCenterX
	title.y = 200

	local playButton = display.newText( sceneGroup, "Play", display.contentCenterX, 740, native.systemFont, 44 )
	playButton:setFillColor( 0.82, 0.86, 1 )

	local highScoresButton = display.newText( sceneGroup, "Highscores", display.contentCenterX, 830, native.systemFont, 44 )
	highScoresButton:setFillColor( 0.75, 0.78, 1 )

	local settingsButton = display.newText( sceneGroup, "Settings", display.contentCenterX, 920, native.systemFont, 44 )
	settingsButton:setFillColor( 0.75, 0.78, 1 )

	playButton:addEventListener( "tap", gotoGame )
	highScoresButton:addEventListener( "tap", gotoHighScores )
	settingsButton:addEventListener( "tap", gotoSettings )

	-- Managing audio-setting file when application is first launched
	local filePath = system.pathForFile( "audio-setting.json", system.DocumentsDirectory )
	local file = io.open( filePath )
	if file then -- file exists, application is NOT started for the first time
		io.close( file )
	else -- file does not exists, application is started for the first time
		audioUtils:saveAudioValue( "on" ) -- default value for game audio is "on"
	end
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
