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

local castOODesire = 0;
local castFBDesire = 0;
local castVDDesire = 0;

local abilityOO = nil;
local abilityFB = nil;
local abilityVD = nil;

local hauntTime = 0;
local npcBot = nil;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end

	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end

	if abilityOO == nil then abilityOO = npcBot:GetAbilityByName( "spectre_reality" ) end
	if abilityFB == nil then abilityFB = npcBot:GetAbilityByName( "spectre_spectral_dagger" ) end
	if abilityVD == nil then abilityVD = npcBot:GetAbilityByName( "spectre_haunt" ) end
	hauntDuration = abilityVD:GetSpecialValueInt("duration");
	
	-- Consider using each ability
	castOODesire, castOOLocation = ConsiderOverwhelmingOdds();
	castFBDesire, castFBTarget, stuck = ConsiderFireblast();
	castVDDesire = ConsiderVendetta();

	if ( castOODesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityOO, castOOLocation );
		return;
	end
	
	if ( castFBDesire > 0 ) 
	then
		if stuck ~= nil then
			npcBot:Action_UseAbilityOnLocation( abilityFB, castFBTarget );
			return;
		else
			npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
			return;
		end
	end
	
	if ( castVDDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityVD );
		hauntTime = DotaTime();
		return;
	end

	
end

function ConsiderOverwhelmingOdds()


	-- Make sure it's castable
	if ( not abilityOO:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	if DotaTime() > hauntTime + hauntDuration then
		return BOT_ACTION_DESIRE_NONE
	end	
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and not mutil.IsInRange(npcTarget, npcBot, 550)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation( );
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderFireblast()

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityFB:GetCastRange();
	local nRadius = abilityFB:GetSpecialValueInt("dagger_radius");
	local nDamage = abilityFB:GetSpecialValueInt("damage")

	if mutil.IsStuck(npcBot)
	then
		local loc = mutil.GetEscapeLoc();
		return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsTowardsLocation( loc, nCastRange/2 ), true;
	end
	
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy)  ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
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

function ConsiderVendetta()

	if ( not abilityVD:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and not mutil.IsInRange(npcTarget, npcBot, 600) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE;
end

