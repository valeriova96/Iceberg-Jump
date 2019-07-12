----------------------------------------------------------------------
-- A little library for those shared functions that manage highscores --
----------------------------------------------------------------------

-- Variables and libraries
local Highscores = { }
local json = require( "json" )
local filePath = system.pathForFile( "scores.json", system.DocumentsDirectory )


-- Functions --
function Highscores:loadScores()
	local file = io.open( filePath, "r" )
	local scoresTable = { }
 
    if file then
        local contents = file:read( "*a" )
        io.close( file )
        scoresTable = json.decode( contents )
    end
 
    if ( scoresTable == nil or #scoresTable == 0 ) then
        scoresTable = { 279, 1000, 500, 570, 190, 3000, 4000, 5000, 456, 654 } -- the default scoresTable
    end

	return scoresTable
end

function Highscores:saveScores( scoresTable )
 
    for i = #scoresTable, 11, -1 do
        table.remove( scoresTable, i )
    end
 
    local file = io.open( filePath, "w" )
 
    if file then
        file:write( json.encode( scoresTable ) )
        io.close( file )
    end
end

function Highscores:getPlayerName( score )
	if ( score == 279 ) then
		return "Gianmarco"
	elseif ( score == 1000 ) then
		return "Marco"
	elseif ( score == 500 ) then
		return "Elisa"
	elseif ( score == 570 ) then
		return "Giovanna"
	elseif ( score == 190 ) then
		return "Andrea"
	elseif ( score == 3000 ) then
		return "Luca"
	elseif ( score == 4000 ) then
		return "Stefano"
	elseif ( score == 5000 ) then
		return "Dario"
	elseif ( score == 456 ) then
		return "Giulia"
	elseif ( score == 654 ) then
		return "Arianna"
	else
		return "Io"
	end
end

function Highscores:findLastHighscorePos( scoresTable )
	for i = 1, #scoresTable do
		if ( self:getPlayerName(scoresTable[i])=="Io" ) then
			return i
		end
	end
	return -1
end

local function compare( a, b )
	return a > b
end
function Highscores:sortScores( scoresTable )
	table.sort( scoresTable, compare )
	return scoresTable
end
----

return Highscores