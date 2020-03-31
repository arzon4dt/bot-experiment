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

local castCDDesire = 0;
local castEHDesire = 0;
local castNSDesire = 0;

local abilityCD = nil;
local abilityEH = nil;
local abilityNS = nil;

local npcBot = GetBot();

function AbilityUsageThink()

	-- Check if we're already using an ability
	if npcBot:HasModifier("modifier_spirit_breaker_charge_of_darkness") then
		npcBot:Action_ClearActions(false);
		return
	end
	
	if ( npcBot:HasModifier("modifier_spirit_breaker_charge_of_darkness") or mutil.CanNotUseAbility(npcBot) or npcBot:NumQueuedActions() > 0 ) then return end;

	if abilityCD == nil then abilityCD = npcBot:GetAbilityByName( "spirit_breaker_charge_of_darkness" ) end
	if abilityEH == nil then abilityEH = npcBot:GetAbilityByName( "spirit_breaker_bulldoze" ) end
	if abilityNS == nil then abilityNS = npcBot:GetAbilityByName( "spirit_breaker_nether_strike" ) end

	castEHDesire = ConsiderEmpoweringHaste();
	castCDDesire, castCDTarget = ConsiderCharge();
	castNSDesire, castNSTarget = ConsiderNetherStrike();
	
	if abilityCD:GetCooldownTimeRemaining() > 0 and npcBot.chargeTarget ~= nil 
	then npcBot.chargeTarget = nil end
	
	if ( castNSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityNS, castNSTarget );
		return;
	end

	if ( castEHDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityEH );
		return;
	end
	
	if ( castCDDesire > 0 ) 
	then
		npcBot:Action_ClearActions(true);
		npcBot.chargeTarget = castCDTarget;
		npcBot:ActionQueue_UseAbilityOnEntity( abilityCD, castCDTarget );
		npcBot:ActionQueue_Delay( 1.0 );
		return;
	end
	
end


function ConsiderEmpoweringHaste()

	-- Make sure it's castable
	if ( not abilityEH:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local AttackRange = npcBot:GetAttackRange();
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
		if ( npcBot:WasRecentlyDamagedByAnyHero(2.0) or npcBot:WasRecentlyDamagedByTower(2.0) or ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1  ) )
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		local dist = GetUnitToUnitDistance( npcBot, npcTarget );
		if  mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 2*AttackRange)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderCharge()

	-- Make sure it's castable
	if ( not abilityCD:IsFullyCastable() or npcBot:IsRooted() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = npcBot:GetAttackRange() + 150;
	
	if mutil.IsRetreating(npcBot) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local enemyCreeps = GetUnitList(UNIT_LIST_ENEMY_CREEPS );
		for _,creep in pairs(enemyCreeps) 
		do
			if GetUnitToUnitDistance(creep, npcBot) > 2500 and mutil.CanCastOnNonMagicImmune(creep) then
				return BOT_ACTION_DESIRE_MODERATE, creep;
			end
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and
			not mutil.IsDisabled(true, npcTarget) ) 
		then
			local Ally = npcTarget:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
			local Enemy = npcTarget:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
			if ( #Ally + 1 >= #Enemy  ) or npcTarget:GetHealth() <= ( 100 + (5*npcBot:GetLevel()) ) then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end	
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderNetherStrike()

	-- Make sure it's castable
	if ( not abilityNS:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityNS:GetCastRange();
	local nDamage = abilityNS:GetAbilityDamage();
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if mutil.CanCastOnMagicImmune(npcEnemy) and ( npcEnemy:IsChanneling() or mutil.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL ) )
		then
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) and
			not mutil.IsDisabled(true, npcTarget) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end
