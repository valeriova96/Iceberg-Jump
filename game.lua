io.output():setvbuf("no")
display.setStatusBar(display.HiddenStatusBar)

local composer = require( "composer" )
local scene = composer.newScene()

local getTimer = system.getTimer
local mRand = math.random
local mAbs = math.abs

local newImageRect = display.newImageRect
local newRect = display.newRect

local isValid = function ( obj ) 
	return ( obj and obj.removeSelf and type(obj.removeSelf) == "function" )
end

local listen = function( name, listener ) 
	Runtime:addEventListener( name, listener ) 
end

local autoIgnore = function( name, obj ) 
   if( not isValid( obj ) ) then
      ignore( name, obj )
      obj[name] = nil
      return true
   end
   return false 
end

local post = function( name, params )
   params = params or {}
   local event = {}
   for k,v in pairs( params ) do event[k] = v end
   if( not event.time ) then event.time = getTimer() end
   event.name = name
   Runtime:dispatchEvent( event )
end

-- =============================================================
-- The Game (line count starts here)
-- =============================================================
local physics = require "physics"
physics.start()
physics.setGravity(0,20)



local centerX  = display.contentCenterX
local centerY  = display.contentCenterY
local fullw  	= display.actualContentWidth
local fullh  	= display.actualContentHeight
local left   	= centerX - fullw/2
local right  	= centerX + fullw/2
local top    	= centerY - fullh/2
local bottom 	= centerY + fullh/2
--
local gameIsRunning = true
local horizSpeed    = 200
local jumpSpeed 	  = 650
local cameraOffset  = 25
local objects		  = {}
local pickupCount   = 0
local distance      = 0
local score = 0

--
local player
local platformsTable = {}
local springsTable = {}
local coinsTable = {}
local spikesTable = {}
local layers
local lastY
local lastX

function display.newGroup2( insertInto )
	local group = display.newGroup()
	if( insertInto ) then insertInto:insert( group ) end
	return group
end

layers = display.newGroup2()
layers.underlay = display.newGroup2( layers )
layers.world = display.newGroup2( layers )
layers.background = display.newGroup2( layers.world )
layers.content = display.newGroup2( layers.world )
layers.overlay = display.newGroup2( layers )
--
local background = display.newImageRect( layers.underlay, "background.png", 720, 1140 )
background.x = display.contentCenterX
background.y = display.contentCenterY
--
local function onTouch( self, event )
	event.name = self.eventName 
	Runtime:dispatchEvent( event ) 
	return false
end

local leftTouch = newImageRect( layers.underlay, "fillT.png", fullw/2, fullh )
leftTouch.anchorX = 0
leftTouch.x = left
leftTouch.y = centerY
leftTouch.eventName = "onTwoTouchLeft"
leftTouch.touch = onTouch
leftTouch:addEventListener("touch")

local rightTouch = newImageRect( layers.underlay, "fillT.png", fullw/2, fullh )
rightTouch.anchorX = 1
rightTouch.x = right
rightTouch.y = centerY
rightTouch.eventName = "onTwoTouchRight"
rightTouch.touch = onTouch
rightTouch:addEventListener("touch")
--

player = newImageRect( layers.content, "player.png", 66, 92 )
player.x = centerX
player.y = centerY + 100


local pyrY = player.y



player.moveLeft = 0
player.moveRight = 0
physics.addBody( player, "dynamic", { bounce = 0.1 } )
player.isFixedRotation = true

local wrapProxy = newImageRect( layers.background, "fillT.png", fullw + 60, fullh )
wrapProxy.x = player.x
wrapProxy.y = player.y


scoreText = display.newText( layers.overlay, "Score: " .. score, centerX, top + 30, "Oxygen-Bold.ttf", 36 )
scoreText:setFillColor(1,1,0)

function scoreText:update()
	self.text = "Score: " .. pickupCount + distance
end

local function endGame()
	composer.setVariable( "finalScore", pickupCount+distance )
	composer.gotoScene( "gameover", { time=300, effect="crossFade" } )
end

function player.preCollision( self, event )
	pyrY = self.y
	local contact 		= event.contact
	local other 		= event.other
	if( other.isDanger or other.isPickup ) then
		-- skip
	elseif( contact and contact.isEnabled ) then
		if( (self.y - other.y) > -(self.contentHeight/2 + other.contentHeight/2 - 1) ) then
			contact.isEnabled = false
			
			
		end
	end	
	return false
end

player:addEventListener("preCollision")
--
function player.collision( self, event )
	local other 		= event.other
	if( event.phase == "began" ) then
		local vx, vy = self:getLinearVelocity()
		if( other.isDanger ) then
			gameIsRunning = false
			self:removeEventListener("preCollision")
			self:removeEventListener("collision")
			scoreText:setFillColor(1,0,0)
			--nextFrame(
			timer.performWithDelay( 1,
				function()
					self.isSensor = true
					self:applyAngularImpulse( mRand( -360, 360 ) )
					--physics.stop(self)
				end )
			-- next line terminates game after collision
			timer.performWithDelay( 1400, endGame )

		elseif( other.isPickup ) then
			pickupCount = pickupCount + 100
			scoreText:update()
			display.remove(other)
			for i = #coinsTable, 1, -1 do

				local thisCoin = coinsTable[i]
		 
				if ( thisCoin == other )
				then
					display.remove( thisCoin )
					table.remove( coinsTable, i )
				end
		 
			end
		
		elseif( other.isSpring and not other.open and vy > 0 ) then
			self:setLinearVelocity( vx, -jumpSpeed * 1.25 )
			other.open = true
			
			timer.performWithDelay( 50,  function() other.fill = { type = "image", filename = "springboardUp.png" } end )
		
		elseif( other.isPlatform and vy > 0 ) then
			self:setLinearVelocity( vx, -jumpSpeed  )
		end

	end

	return false

end

player:addEventListener("collision")

local function createGameObject( x, y, objectType )
	x = x or lastX
	y = y or lastY
	if( not gameIsRunning ) then return nil end
	local obj
	if( objectType == "platform" ) then
		
		obj = newImageRect( layers.background, "platform.png", 210, 70 )
		obj.x = x
		obj.y = y
		obj.isPlatform = true
		obj.anchorY = 0
		physics.addBody( obj, "static", { bounce = 0 } )
		lastX = x
		lastY = y
		table.insert( platformsTable, obj )
		

	elseif( objectType == "spring" ) then
		
		obj = newImageRect( layers.background, "springboardDown.png", 70, 70 )
		obj.x = x + mRand(-40, 40)
		obj.y = y
		obj.isSpring = true
		obj.anchorY = 1
		physics.addBody( obj, "static", { bounce = 0, shape = {-35, 0, 35, 0, 35, 35, -35, 35 } } )
		table.insert( springsTable, obj )
	
	elseif( objectType == "pickup" ) then
		
		obj = newImageRect( layers.background, "coinGold.png", 70, 70 )
		obj.x = x + mRand(-40, 40)
		obj.y = y
		obj.isPickup = true
		obj.anchorY = 1
		physics.addBody( obj, "static", { bounce = 0 } )
		obj.isSensor = true
		table.insert( coinsTable, obj )
	
	elseif( objectType == "danger" ) then
		
		obj = newImageRect( layers.background, "spikes.png", 70, 70 )
		obj.x = x + mRand(-40, 40)
		obj.y = y
		obj.isDanger = true
		obj.anchorY = 1
		physics.addBody( obj, "static", { bounce = 0, shape = {-35, 0, 35, 0, 35, 35, -35, 35 } } )
		obj.isSensor = true
		table.insert( spikesTable, obj )
		
	end
	--
	function obj.finalize( self )
		objects[self] = nil
	end

end

local function levelGen( noItems )

	while lastY > (player.y - fullh * 0.75) do
		createGameObject( centerX + mRand( -200, 200 ) , lastY - mRand( 100, 300 ), "platform" )		

		
		if( not noItems and mRand( 1, 100 ) > 20 ) then
			local items = { "danger", "pickup", "pickup", "spring", "spring", "spring"  }
			createGameObject( nil, nil, items[mRand(1,#items)] )
		end
	end

	-- Rimuovo le piattaforme che sono sotto la visuale dello schermo
    for i = #platformsTable, 1, -1 do

        local thisPlatform = platformsTable[i]
 
		if ( thisPlatform.y > centerY+player.y)
		then
            display.remove( thisPlatform )
			table.remove( platformsTable, i )
			break
        end
 
	end
	-- Rimuovo le molle che sono sotto la visuale dello schermo
    for i = #springsTable, 1, -1 do

        local thisSpring = springsTable[i]
 
		if ( thisSpring.y > centerY+player.y)
		then
            display.remove( thisSpring )
			table.remove( springsTable, i )
			break
        end
 
	end

end
--
function player.enterFrame( self )	
	while(gameIsRunning==true) do

	if( self.y > pyrY + 1000) then
		gameIsRunning = false
		self:removeEventListener("preCollision")
		self:removeEventListener("collision")
		scoreText:setFillColor(1,0,0)
		--nextFrame(
		timer.performWithDelay( 1,
			function()
				self.isSensor = true
				self:applyAngularImpulse( mRand( -360, 360 ) )
				--physics.stop(self)
			end )
		-- next line terminates game after player is out of screen
		timer.performWithDelay( 1400, endGame )
	end
	if( not autoIgnore( "enterFrame", self ) ) then 
		self.minY = self.minY or self.y
		self.lastY = self.lastY or self.y

		if( self.y < self.lastY ) then
			layers.world.y = layers.world.y + (self.lastY - self.y) 
			self.lastY = self.y
			levelGen()
		end

		--local dist = round(self.minY - self.y)	
		local dist = math.round(self.minY - self.y)	-- same result for base case, but not same as SSK version
		if( dist > distance ) then 
			distance = dist 
			scoreText:update()
		end
		--
		wrapProxy.y = self.y
	
		local right = wrapProxy.x + wrapProxy.contentWidth / 2
		local left  = wrapProxy.x - wrapProxy.contentWidth / 2
		local top = wrapProxy.y - wrapProxy.contentHeight / 2
		local bot  = wrapProxy.y + wrapProxy.contentHeight / 2
		if(self.x >= right) then
			self.x = left + self.x - right
		elseif(self.x <= left) then 
			self.x = right + self.x - left
		end
		if(self.y >= bot) then
			self.y = top + self.y - bot
		elseif(self.y <= top) then 
			self.y = bot + self.y - top
		end


		--
		local vx, vy = self:getLinearVelocity()
		vx = 0
		vx = vx - self.moveLeft * horizSpeed
		vx = vx + self.moveRight * horizSpeed
		self:setLinearVelocity( vx, vy )
	end
	return false
    end
end

listen("enterFrame",player)

function player.onTwoTouchLeft( self, event )
	if( event.phase == "began" ) then
		self.moveLeft = 1
	elseif( event.phase == "ended" ) then
	self.moveLeft = 0
	end
end

listen( "onTwoTouchLeft", player )

function player.onTwoTouchRight( self, event )
	if( event.phase == "began" ) then
		self.moveRight = 1
	elseif( event.phase == "ended" ) then
	self.moveRight = 0
	end
end

listen( "onTwoTouchRight", player )

--
createGameObject( player.x, player.y + 100, "platform" )
levelGen(true)

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen --
	sceneGroup:insert(layers)
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
		Runtime:removeEventListener( "enterFrame", player )
		Runtime:removeEventListener( "onTwoTouchLeft", player )
		Runtime:removeEventListener( "onTwoTouchRight", player )
		physics.stop()
		composer.removeScene( "game" )
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
