------------------------------------------------------------------------
-- A little library for those shared functions that manage highscores --
------------------------------------------------------------------------

-- Variables and libraries
local Highscores = { }
local json = require( "json" )
local playerUtils = require( "playerUtils" )
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
        scoresTable = { 2790, 1600, 30543, 42768, 67100, 10205, 8978, 5060, 13456, 6540 } -- the default scoresTable
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
	if ( score == 2790 ) then
		return "GianmaBig"
	elseif ( score == 1600 ) then
		return "Marco"
	elseif ( score == 67100 ) then
		return "elisa"
	elseif ( score == 42768 ) then
		return "Giova"
	elseif ( score == 30543 ) then
		return "ErMacina"
	elseif ( score == 10205 ) then
		return "alwayswin"
	elseif ( score == 8978 ) then
		return "stefy"
	elseif ( score == 5060 ) then
		return "DariOne"
	elseif ( score == 13456 ) then
		return "bigplayer"
	elseif ( score == 6540 ) then
		return "ari96"
	else
		return playerUtils:getPlayerName(  )
	end
end

function Highscores:findLastHighscorePos( scoresTable )
	local playerName = playerUtils:getPlayerName(  )
	for i = 1, #scoresTable do
		if ( self:getPlayerName(scoresTable[i])==playerName ) then
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