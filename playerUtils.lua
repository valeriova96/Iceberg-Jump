-----------------------------------------------------------------------------
-- A little library for those shared functions that manage player settings --
-----------------------------------------------------------------------------

-- Variables and libraries
local Player = { }
local json = require( "json" )
-- The file in which is saved the last audio setting
local filePath = system.pathForFile( "playername.json", system.DocumentsDirectory )

-- Functions --
-- Retrieves the last value saved from file
function Player:getPlayerName(  )
	local file = io.open( filePath, "r" )
	local value-- = { }

	if file then
		local content = file:read( "*a" )
		io.close( file )
		value = json.decode( content )
	end
	
	return value
end

-- Saves a new player name into the file
function Player:savePlayerName( newValue )
	local file = io.open( filePath, "w" )

	if file then
		file:write( json.encode( newValue ) )
		io.close( file )
	end
end
----

return Player