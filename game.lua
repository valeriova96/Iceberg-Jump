io.output():setvbuf("no")
display.setStatusBar(display.HiddenStatusBar)

local getTimer = system.getTimer
local mRand = math.random
local mAbs = math.abs

local newImageRect = display.newImageRect
local newRect = display.newRect

local background = display.newImageRect( "background.png", 720, 1140 )
background.x = display.contentCenterX
background.y = display.contentCenterY

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
--piccolo counter per capire se le piattaforme nell'array
--vengono effettivamente aggiunte/rimosse
local p = 0
local numberOfPlatform = display.newText("Platforms: " .. p, centerX + 200, top + 30, "Oxygen-Bold.ttf", 36 )
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
player.moveLeft = 0
player.moveRight = 0
physics.addBody( player, "dynamic", { bounce = 0.1 } )
player.isFixedRotation = true

local wrapProxy = newImageRect( layers.background, "fillT.png", fullw + 60, fullh )
wrapProxy.x = player.x
wrapProxy.y = player.y


scoreText = display.newText("Score: " .. score, centerX, top + 30, "Oxygen-Bold.ttf", 36 )
scoreText:setFillColor(1,1,0)

function scoreText:update()
	self.text = "Score: " .. pickupCount + distance
end

function player.preCollision( self, event )
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
				end )
		
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

		--elseif(player.y > 100 ) then
		    --gameIsRunning = false
		    --self:removeEventListener("preCollision")
		    --self:removeEventListener("collision")
		    --scoreText:setFillColor(1,0,0)
		    --timer.performWithDelay( 1,
			--function()
				--self.isSensor = true
				--self:applyAngularImpulse( mRand( -360, 360 ) )
			--end )
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
		--piccolo counter per capire se le piattaforme nell'array
		--vengono effettivamente aggiunte/rimosse
		p = p + 1
		numberOfPlatform.text = "Platforms: " .. p
		

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
			pY = thisPlatform.y
            display.remove( thisPlatform )
			table.remove( platformsTable, i )
			--piccolo counter per capire se le piattaforme nell'array
		    --vengono effettivamente aggiunte/rimosse
			p = p - 1
			numberOfPlatform.text = "Platforms: " .. p
			break
        end
 
	end

end
--
function player.enterFrame( self )	
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
end; 

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




--piccolo counter per capire se le piattaforme nell'array
--vengono effettivamente aggiunte/rimosse
local function updateP()
	numberOfPlatform.text = "Platforms: " .. p
end

--
createGameObject( player.x, player.y + 100, "platform" )
levelGen(true)
