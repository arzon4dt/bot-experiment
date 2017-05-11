------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
mode_roam_generic = dofile( GetScriptDirectory().."/ps/mode_roam_generic" )
Utility = require(GetScriptDirectory().."/ps/Utility")
----------

function OnStart()
	mode_roam_generic.OnStart();
end

function OnEnd()
	mode_roam_generic.OnEnd();
end

function GetDesire()
	return mode_roam_generic.GetDesire();
end

function Think()
	mode_roam_generic.Think();
end

--------
