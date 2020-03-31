if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local mutil = require(GetScriptDirectory() ..  "/MyUtility")

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end
function ItemUsageThink()
	ability_item_usage_generic.ItemUsageThink();
end

local castESDesire = 0;
local castVODesire = 0;
local castFGDesire = 0;

local abilityES = nil;
local abilityVO = nil;
local abilityFG = nil;

local npcBot = nil;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end

	if abilityES == nil then abilityES = npcBot:GetAbilityByName( "visage_grave_chill" ) end
	if abilityVO == nil then abilityVO = npcBot:GetAbilityByName( "visage_soul_assumption" ) end
	if abilityFG == nil then abilityFG = npcBot:GetAbilityByName( "visage_summon_familiars" ) end
	
	
	-- Consider using each ability
	castESDesire, castESTarget = ConsiderEtherShock();
	castVODesire, castVOTarget = ConsiderVoodoo();
	castFGDesire, castFGTarget = ConsiderFleshGolem();

	if ( castESDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityES, castESTarget );
		return;
	end
	
	if ( castVODesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityVO, castVOTarget );
		return;
	end
	if ( castFGDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityFG );
		return;
	end
	
	
end


function ConsiderEtherShock()

	-- Make sure it's castable
	if ( not abilityES:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityES:GetCastRange();
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy)  ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if mutil.CanCastOnNonMagicImmune(npcEnemy) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderVoodoo()

	-- Make sure it's castable
	if ( not abilityVO:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local SAStack = 0;
	local npcModifier = npcBot:NumModifiers();
	
	for i = 0, npcModifier 
	do
		if npcBot:GetModifierName(i) == "modifier_visage_soul_assumption" then
			SAStack = npcBot:GetModifierStackCount(i);
			break;
		end
	end
	
	local nCastRange = abilityVO:GetCastRange();
	local nStackLimit = abilityVO:GetSpecialValueInt("stack_limit");
	local nBaseDamage = abilityVO:GetSpecialValueInt("soul_base_damage");
	local nChargeDamage = abilityVO:GetSpecialValueInt("soul_charge_damage");
	local nTotalDamage = nBaseDamage + (SAStack * nChargeDamage);
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If a mode has set a target, and we can kill them, do it
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if mutil.CanKillTarget(npcEnemy, nTotalDamage, DAMAGE_TYPE_MAGICAL ) and mutil.CanCastOnNonMagicImmune(npcEnemy) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) and SAStack == nStackLimit ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if mutil.IsValidTarget(npcEnemy) and mutil.CanCastOnNonMagicImmune(npcEnemy) and SAStack == nStackLimit
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) 
		   and SAStack == nStackLimit
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderFleshGolem()

	-- Make sure it's castable
	if ( not abilityFG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local numFamiliar = 0;
	
	local listFamiliar = GetUnitList(UNIT_LIST_ALLIES);
	for _,unit in pairs(listFamiliar)
	do
		if string.find(unit:GetUnitName(), "npc_dota_visage_familiar") then
			numFamiliar = numFamiliar + 1;
		end
	end
	
	if numFamiliar < 1 then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	return BOT_ACTION_DESIRE_NONE;
end
