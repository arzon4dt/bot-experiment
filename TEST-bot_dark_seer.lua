--local minion = dofile( GetScriptDirectory().."/MinionUtility" )
local minion = require( GetScriptDirectory().."/MinionUtility" )


function  MinionThink(  hMinionUnit ) 
	
	minion.GeneralMinionThink(hMinionUnit)
	
end
