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
function  OnStart()
end

function OnEnd()
end

function GetDesire()
	if DotaTime() < 10*60 then
		return BOT_MODE_DESIRE_VERYLOW;
	end
	return BOT_MODE_DESIRE_MODERATE ;
end

function Think()
end

--------
MyModule.OnStart = OnStart;
MyModule.OnEnd = OnEnd;
MyModule.Think = Think;
MyModule.GetDesire = GetDesire;
return MyModule;