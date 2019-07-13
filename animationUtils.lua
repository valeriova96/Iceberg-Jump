--------------------------------------------
-- A little library for buttons animation --
--------------------------------------------

-- Variables
local Animation = { }

-- Functions --
-- Scale in an object
function Animation:scaleIn( obj )
	transition.scaleTo( obj, { xScale=1.2, yScale=1.2, time=3000,
								onComplete=Animation:scaleOff( obj ) } )
end

-- Scale off an object
function Animation:scaleOff( obj )
	transition.scaleTo( obj, { xScale=1.0, yScale=1.0, time=3000,
								onComplete=Animation:scaleIn( obj ) } )
end
----

return Animation