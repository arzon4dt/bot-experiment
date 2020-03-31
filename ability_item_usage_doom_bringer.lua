if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local skills = require(GetScriptDirectory() ..  "/SkillsUtility")
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

local castDVDesire = 0;
local castSEDesire = 0;
local castIBDesire = 0;
local castDMDesire = 0;

local abilityDV = nil;
local abilitySE = nil;
local abilityIB = nil;
local abilityDM = nil;
local ability3 = nil;
local ability4 = nil;
local devourAnciennt = nil;

local npcBot = nil;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	if abilityDV == nil then abilityDV = npcBot:GetAbilityByName( "doom_bringer_devour" ) end
	if abilitySE == nil then abilitySE = npcBot:GetAbilityByName( "doom_bringer_scorched_earth" ) end
	if abilityIB == nil then abilityIB = npcBot:GetAbilityByName( "doom_bringer_infernal_blade" ) end
	if abilityDM == nil then abilityDM = npcBot:GetAbilityByName( "doom_bringer_doom" ) end
	if devourAnciennt == nil then devourAnciennt = npcBot:GetAbilityByName( "special_bonus_unique_doom_2" ) end
	ability3 = npcBot:GetAbilityInSlot(3) 
	ability4 = npcBot:GetAbilityInSlot(4)
	
	-- Consider using each ability
	castDVDesire, castDVTarget = ConsiderDevour();
	castSEDesire = ConsiderScorchedEarth();
	castIBDesire, castIBTarget = ConsiderInfernalBlade();
	castDMDesire, castDMTarget = ConsiderDoom();
	
	if ( castSEDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilitySE );
		return;
	end
	if ( castDMDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityDM, castDMTarget );
		return;
	end
	
	if ( castIBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityIB, castIBTarget );
		return;
	end

	if ( castDVDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityDV, castDVTarget );
		return;
	end
	
	skills.CastStolenSpells(ability3);
	skills.CastStolenSpells(ability4);
	
end


function ConsiderDevour()
	
	-- Make sure it's castable
	if ( not abilityDV:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if mutil.IsRetreating(npcBot) then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	-- Get some of its values
	local nCastRange = abilityDV:GetCastRange();
	local canEatAncient = false;
	local clvl = abilityDV:GetSpecialValueInt('creep_level');
	
	if devourAnciennt ~= nil and devourAnciennt:IsTrained() then
		canEatAncient = true;
	end
	
	if not mutil.IsRetreating(npcBot) and not mutil.IsGoingOnSomeone(npcBot) 
	--    and not npcBot:HasModifier("modifier_doom_bringer_devour") 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( nCastRange+200, true );
		for _,npcCreep in pairs( tableNearbyEnemyCreeps )
		do
			if ( mutil.CanCastOnNonMagicImmune(npcCreep) and npcCreep:GetLevel() <= clvl ) then
				return BOT_ACTION_DESIRE_HIGH, npcCreep;
			end
		end
	end	

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderScorchedEarth()

	-- Make sure it's castable
	if ( not abilitySE:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nRadius = abilitySE:GetSpecialValueInt( "radius" );
	local nCastRange = 1000;

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderInfernalBlade()

	-- Make sure it's castable
	if ( not abilityIB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityIB:GetCastRange();
	local nDamage = 1000;

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() and mutil.CanCastOnNonMagicImmune(npcEnemy)  ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
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

function ConsiderDoom()

	-- Make sure it's castable
	if ( not abilityDM:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityDM:GetCastRange();
	local nDamage = 700;

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're in a teamfight, use it on the scariest enemy
	if mutil.IsInTeamFight(npcBot, 1200)
	then

		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnMagicImmune(npcEnemy) )
			then
				local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_ALL );
				if ( nDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = nDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end

		if ( npcMostDangerousEnemy ~= nil  )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
		end
	end
	
	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() and  mutil.CanCastOnMagicImmune(npcEnemy) ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
		if tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes >= 2 then
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and  mutil.CanCastOnMagicImmune(npcEnemy)  ) 
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy;
				end
			end
		end
	end

	-- If we're going after someone
	if  mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange) ) 
		then
			local allies = npcTarget:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
			if allies ~= nil and #allies >= 2 then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end
