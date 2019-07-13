-- Scene and settings library imports
local composer = require( "composer" )
local scene = composer.newScene()

local audioUtils = require( "audioUtils" )

local playerUtils = require( "playerUtils" )

-- Functions and variables
local sceneGroup
local audioIcon
local inputTextField

local function gotoMenu(  )
	composer.gotoScene( "menu", { time=300, effect="crossFade" } )
end

-- Changes audio value in settings file and refresh the icon
local function changeAudioValue(  )
	local oldValue = audioUtils:lastAudioValue(   )
	
	display.remove( audioIcon )
	audioIcon = nil

	if ( oldValue=="on" ) then
		audioUtils:saveAudioValue( "off" )
		audioIcon = display.newImageRect( sceneGroup, "audio-off-icon.png", 180, 180 )
	else
		audioUtils:saveAudioValue( "on" )
		audioIcon = display.newImageRect( sceneGroup, "audio-on-icon.png", 180, 180 )
	end
	
	audioIcon.x = display.contentCenterX
	audioIcon.y = 400
	audioIcon:addEventListener( "tap", changeAudioValue )

end

local function inputTextHandler( event )
	if ( event.phase == "began" ) then
		-- before editing phase
		
	elseif ( event.phase == "ended" or event.phase == "submitted" ) then
		-- on text confirmation, editing phase terminated
		playerUtils:savePlayerName( event.target.text )

	elseif ( event.phase == "editing" ) then
		-- during editing phase

	end
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	
	-- Composing screen texts and buttons --
	local background = display.newImageRect( sceneGroup, "background.png", 800, 1400 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	local title = display.newImageRect( sceneGroup, "settings.png", 620, 181 )
	title.x = display.contentCenterX
	title.y = 100

	local infoAudioText = display.newText( sceneGroup, "Clicca sull'icona per audio on/off", display.contentCenterX - 60, 250, native.systemFont, 32 )
    infoAudioText:setFillColor( 0.75, 0.78, 1 )
	audioIcon = display.newImageRect( sceneGroup,
			"audio-" .. audioUtils:lastAudioValue() .. "-icon.png", 
			180, 180 )
	audioIcon.x = display.contentCenterX
	audioIcon.y = 400
	audioIcon:addEventListener( "tap", changeAudioValue )

	local infoPlayernameText = display.newText( sceneGroup, "Clicca sul nickname per modificarlo", display.contentCenterX - 40, 560, native.systemFont, 32 )
    infoPlayernameText:setFillColor( 0.75, 0.78, 1 )

	local menuBtn = display.newImageRect(sceneGroup, "menuBtn.png", 300, 120)
	menuBtn.x = display.contentCenterX
	menuBtn.y = 950
    menuBtn:addEventListener( "tap", gotoMenu )

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		inputTextField = native.newTextField( display.contentCenterX - 93, 630, 400, 60 )
		inputTextField:setTextColor( 0.75, 0.78, 1 )
		inputTextField.text = playerUtils:getPlayerName(  )
		inputTextField.hasBackground = false
		inputTextField:addEventListener( "userInput", inputTextHandler )
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		inputTextField:removeSelf()
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		composer.removeScene( "settings" )
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
