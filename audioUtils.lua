----------------------------------------------------------------------------
-- A little library for those shared functions that manage audio settings --
----------------------------------------------------------------------------

-- Variables and libraries
local Audio = { }
local json = require( "json" )
-- The file in which is saved the last audio setting
local filePath = system.pathForFile( "audio-setting.json", system.DocumentsDirectory )

-- Functions --
-- Retrieves the last value saved from file
function Audio:lastAudioValue(  )
	local file = io.open( filePath, "r" )
	local value-- = { }

	if file then
		local content = file:read( "*a" )
		io.close( file )
		value = json.decode( content )
	end
	
	return value
end

-- Saves a new value (on or off) into the file
function Audio:saveAudioValue( newValue )
	local file = io.open( filePath, "w" )

	if file then
		file:write( json.encode( newValue ) )
		io.close( file )
	end
end
----

return Audio