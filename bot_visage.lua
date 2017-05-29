local utils = require(GetScriptDirectory() ..  "/util")
local npcBot = GetBot();
local castSFDesire = 0;
local MoveDesire = 0;
local AttackDesire = 0;
local npcBotAR = 0;
local ProxRange = 1200;
function  MinionThink(  hMinionUnit ) 

if not hMinionUnit:IsNull() and hMinionUnit ~= nil then 
	if string.find(hMinionUnit:GetUnitName(), "npc_dota_visage_familiar") then
		if ( hMinionUnit:IsUsingAbility() or not hMinionUnit:IsAlive() ) then return end
		
		abilitySF = hMinionUnit:GetAbilityByName( "visage_summon_familiars_stone_form" );
		castSFDesire = ConsiderStoneForm(hMinionUnit);
		AttackDesire, AttackTarget = ConsiderAttacking(hMinionUnit); 
		MoveDesire, Location = ConsiderMove(hMinionUnit); 
		RetreatDesire, RetreatLocation = ConsiderRetreat(hMinionUnit); 
		
		
		if castSFDesire > 0 then
			--print("sf")
			hMinionUnit:Action_UseAbility(abilitySF);
			return
		end
		if ( RetreatDesire > 0 ) 
		then
			--print("retreat")
			hMinionUnit:Action_MoveToLocation( RetreatLocation );
			return;
		end
		if (AttackDesire > 0)
		then
			--print("attack")
			hMinionUnit:Action_AttackUnit( AttackTarget, true );
			return
		end
		if (MoveDesire > 0)
		then
			--print("move")
			hMinionUnit:Action_MoveToLocation( Location );
			return
		end
		
	end
end
	
end

function CanBeAttacked( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end

function IsDisabled(npcTarget)
	if npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) or npcTarget:IsNightmared( ) or npcTarget:IsSilenced( ) then
		return true;
	end
	return false;
end

function GetBase()
	local RB = Vector(-7200,-6666)
	local DB = Vector(7137,6548)
	if GetTeam( ) == TEAM_DIRE then
		return DB;
	elseif GetTeam( ) == TEAM_RADIANT then
		return RB;
	end
end

function ConsiderStoneForm(hMinionUnit)
	
	if not abilitySF:IsFullyCastable() or 
	   hMinionUnit:HasModifier("modifier_visage_summon_familiars_stone_form_buff") 	
	then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = abilitySF:GetSpecialValueInt("stun_radius");
	local nHealth = hMinionUnit:GetHealth() / hMinionUnit:GetMaxHealth();
	local SAStack = 0;
	local npcModifier = hMinionUnit:NumModifiers();
	for i = 0, npcModifier 
	do
		if hMinionUnit:GetModifierName(i) == "modifier_visage_summon_familiars_damage_charge" then
			SAStack = hMinionUnit:GetModifierStackCount(i);
			break;
		end
	end
	
	if nHealth < 0.55 then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if SAStack < 1 then
		local tableNearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
	
end

function ConsiderAttacking(hMinionUnit)
	
	if hMinionUnit:HasModifier("modifier_visage_summon_familiars_stone_form_buff") 	
	then
		return BOT_ACTION_DESIRE_NONE, {};
	end	
	
	local target = npcBot:GetAttackTarget();
	local AR = hMinionUnit:GetAttackRange();
	local OAR = npcBot:GetAttackRange();
	local AD = hMinionUnit:GetAttackDamage();
	
	if target ~= nil and CanBeAttacked(target) and GetUnitToUnitDistance(hMinionUnit, npcBot) <= ProxRange then
		return BOT_ACTION_DESIRE_MODERATE, target;	
	end
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderMove(hMinionUnit)

	if hMinionUnit:HasModifier("modifier_visage_summon_familiars_stone_form_buff") or not npcBot:IsAlive() or GetUnitToUnitDistance(hMinionUnit, npcBot) < 100
	then
		return BOT_ACTION_DESIRE_NONE, {};
	end	
	
	local target = npcBot:GetAttackTarget()
	
	if target == nil or ( target ~= nil and not CanBeAttacked(target) ) or (target ~= nil and GetUnitToUnitDistance(target, npcBot) > ProxRange) then
		return BOT_ACTION_DESIRE_MODERATE, npcBot:GetXUnitsTowardsLocation(GetAncient(GetOpposingTeam()):GetLocation(), 200);
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

function ConsiderRetreat(hMinionUnit)
	
	if hMinionUnit:HasModifier("modifier_visage_summon_familiars_stone_form_buff") or hMinionUnit:DistanceFromFountain() == 0 
	then
		return BOT_ACTION_DESIRE_NONE, {};
	end	

	if not npcBot:IsAlive() then
		local loc = GetBase()
		return BOT_ACTION_DESIRE_HIGH, loc;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
