local npcBot = GetBot();
local moveDesire = 0;
local attackDesire = 0;
local ProxRange = 1300;

function  MinionThink(  hMinionUnit ) 	
	if not hMinionUnit:IsNull() and hMinionUnit ~= nil then
		if IsTombStone(hMinionUnit:GetUnitName()) then
			return
		elseif hMinionUnit:IsIllusion() then
			return;
		end
	end
end

function IsTombStone(sName)
	return sName == 'npc_dota_unit_tombstone1' or sName == 'npc_dota_unit_tombstone2' or sName == 'npc_dota_unit_tombstone3';
end