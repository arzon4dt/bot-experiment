------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
BotsInit = require( "game/botsinit" );

local MyModule = BotsInit.CreateGeneric();

----------
Utility = require( GetScriptDirectory().."/ps/Utility")
----------
-------------
-- This is for getting back when the hero is getting hit under a tower
-------------
function  OnStart()
end

function OnEnd()
end

function GetDesire()
	return 0.0;
end

function Think()
end

--------
MyModule.OnStart = OnStart;
MyModule.OnEnd = OnEnd;
MyModule.Think = Think;
MyModule.GetDesire = GetDesire;
return MyModule;