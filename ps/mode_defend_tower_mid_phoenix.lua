------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
mode_defend_tower_mid_generic = dofile( GetScriptDirectory().."/ps/mode_defend_tower_mid_generic" )
Utility = require(GetScriptDirectory().."/ps/Utility")
----------

function OnStart()
	mode_defend_tower_mid_generic.OnStart();
end

function OnEnd()
	mode_defend_tower_mid_generic.OnEnd();
end

function GetDesire()
	return mode_defend_tower_mid_generic.GetDesire();
end

function Think()
	mode_defend_tower_mid_generic.Think();
end

--------
