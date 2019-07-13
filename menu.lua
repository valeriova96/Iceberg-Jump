-- Scene and libraries for menu scene --
local composer = require( "composer" )
local scene = composer.newScene()

local audioUtils = require( "audioUtils" )

local playerUtils = require( "playerUtils" )

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

local function rotateBack()
	
end

local function rotateForward()

end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	-- Composing scene background, title and buttons --
	local background = display.newImageRect( sceneGroup, "background.png", 800, 1400 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	local title = display.newImageRect( sceneGroup, "title.png", 620, 181 )
	title.x = display.contentCenterX
	title.y = 200

	-- each button has its own animation functions
	local playBtn = display.newImageRect(sceneGroup, "play.png", 280, 100)
	playBtn.x = display.contentCenterX
	playBtn.y = 680
	local scaleInPlay
	local scaleOffPlay
	scaleOffPlay =
			function() 
				transition.scaleTo( playBtn, { xScale=1.0, yScale=1.0, time=500, onComplete=scaleInPlay } )
			end
	scaleInPlay = 
			function()
				transition.scaleTo( playBtn, { xScale=1.1, yScale=1.1, time=500, onComplete=scaleOffPlay } )
			end

	local highScoresBtn = display.newImageRect(sceneGroup, "highscoresBtn.png", 530, 100)
	highScoresBtn.x = display.contentCenterX
	highScoresBtn.y = 820
	local scaleInHighScores
	local scaleOffHighScores
	scaleOffHighScores =
			function() 
				transition.scaleTo( highScoresBtn, { xScale=1.0, yScale=1.0, time=500, onComplete=scaleInHighScores } )
			end
	scaleInHighScores = 
			function()
				transition.scaleTo( highScoresBtn, { xScale=1.1, yScale=1.1, time=500, onComplete=scaleOffHighScores } )
			end

	local settingsBtn = display.newImageRect(sceneGroup, "settingsBtn.png", 430, 100)
	settingsBtn.x = display.contentCenterX
	settingsBtn.y = 960
	local scaleInSettings
	local scaleOffSettings
	scaleOffSettings =
			function() 
				transition.scaleTo( settingsBtn, { xScale=1.0, yScale=1.0, time=500, onComplete=scaleInSettings } )
			end
	scaleInSettings = 
			function()
				transition.scaleTo( settingsBtn, { xScale=1.1, yScale=1.1, time=500, onComplete=scaleOffSettings } )
			end

	playBtn:addEventListener( "tap", gotoGame )
	highScoresBtn:addEventListener( "tap", gotoHighScores )
	settingsBtn:addEventListener( "tap", gotoSettings )

	-- starting animations...
	scaleInPlay()
	scaleInHighScores()
	scaleInSettings()
	
	-- Managing audio-setting and playername files when application is first launched
	local filePath_audio = system.pathForFile( "audio-setting.json", system.DocumentsDirectory )
	local filePath_playername = system.pathForFile( "playername.json", system.DocumentsDirectory )
	local file_audio = io.open( filePath_audio )
	local file_playername = io.open( filePath_playername )
	if file_audio then -- file exists, application is NOT started for the first time
		io.close( file_audio )
	else -- file does not exists, application is started for the first time
		audioUtils:saveAudioValue( "on" ) -- default value for game audio is "on"
	end
	if file_playername then
		io.close( file_playername )
	else
		playerUtils:savePlayerName( "player" ) -- default value for player name is "player"
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
