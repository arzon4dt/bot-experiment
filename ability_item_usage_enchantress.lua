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

local castFBDesire = 0;
local castTDDesire = 0;
local castBSDesire = 0;

local abilityFB = nil;
local abilityTD = nil;
local abilityBS = nil;

local npcBot = nil;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end
	
	if abilityFB == nil then abilityFB = npcBot:GetAbilityByName( "enchantress_enchant" ) end
	if abilityTD == nil then abilityTD = npcBot:GetAbilityByName( "enchantress_natures_attendants" ) end
	if abilityBS == nil then abilityBS = npcBot:GetAbilityByName( "enchantress_impetus" ) end

	-- Consider using each ability
	castFBDesire, castFBTarget = ConsiderFireblast();
	castTDDesire = ConsiderTimeDilation();
	castBSDesire, castBSTarget = ConsiderBurningSpear();
	
	if ( castFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		return;
	end
	
	if ( castTDDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityTD );
		return;
	end
	if ( castBSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityBS, castBSTarget );
		return;
	end

end

function ConsiderFireblast()

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityFB:GetCastRange();

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	--[[local maxHP = 0;
	local NCreep = nil;
	local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( 1200 );
	if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 3 then
		for _,neutral in pairs(tableNearbyNeutrals)
		do
			local NeutralHP = neutral:GetHealth();
			if NeutralHP > maxHP and not neutral:IsAncientCreep()
			then
				NCreep = neutral;
				maxHP = NeutralHP;
			end
		end
	end
	
	if NCreep ~= nil then
		return BOT_ACTION_DESIRE_LOW, NCreep;
	end]]--	
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function ConsiderTimeDilation()

	-- Make sure it's castable
	if ( not abilityTD:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) or ( npcBot:GetHealth() / npcBot:GetMaxHealth() ) < 0.5 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 )) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if (tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 and ( npcBot:GetHealth() / npcBot:GetMaxHealth() ) < 0.55) then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderBurningSpear()

	-- Make sure it's castable
	if ( not abilityBS:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityBS:GetCastRange();
	local nAttackRange = npcBot:GetAttackRange();
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nAttackRange + 200) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end