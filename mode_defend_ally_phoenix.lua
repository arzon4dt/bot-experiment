------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
mode_defend_ally_generic = dofile( GetScriptDirectory().."/ps/mode_defend_ally_generic" )
Utility = require(GetScriptDirectory().."/ps/Utility")
----------

function OnStart()
	mode_defend_ally_generic.OnStart();
end

function OnEnd()
	mode_defend_ally_generic.OnEnd();
end


function GetDesire()
	return mode_defend_ally_generic.GetDesire();
end

function Think()
	mode_defend_ally_generic.Think();
	
	local npcBot=GetBot();
	
	local Enemy=Utility.GetOurEnemy();
	
	if npcBot:IsUsingAbility() or npcBot:IsChanneling() or Enemy==nil then
		return;
	end
	
	if npcBot:IsSilenced() then
		npcBot:Action_AttackUnit(Enemy,true);
	end
end

--------
