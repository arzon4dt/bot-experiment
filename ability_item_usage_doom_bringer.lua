--require(GetScriptDirectory() ..  "/ability_item_usage_generic")
local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local skills = require(GetScriptDirectory() ..  "/SkillsUtility")
--local inspect = require(GetScriptDirectory() ..  "/inspect")
--local enemyStatus = require(GetScriptDirectory() .. "/enemy_status" )

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end

local castDVDesire = 0;
local castSEDesire = 0;
local castIBDesire = 0;
local castDMDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	--[[for i = 0, 24, 1
	do 
		local ability = npcBot:GetAbilityInSlot(i);
		if ability ~= nil then
			print(i..ability:GetName());
		end
	end]]--
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityDV = npcBot:GetAbilityByName( "doom_bringer_devour" );
	abilitySE = npcBot:GetAbilityByName( "doom_bringer_scorched_earth" );
	abilityIB = npcBot:GetAbilityByName( "doom_bringer_infernal_blade" );
	abilityDM = npcBot:GetAbilityByName( "doom_bringer_doom" );
	ability3 = npcBot:GetAbilityInSlot(3);
	ability4 = npcBot:GetAbilityInSlot(4);
	
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

function CanCastInfernalBladeOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastDoomOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end

function enemyDisabled(npcTarget)
	if npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) then
		return true;
	end
	return false;
end


function ConsiderDevour()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityDV:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	-- Get some of its values
	local nCastRange = abilityDV:GetCastRange();
	local canEatAncient = false;
	
	if npcBot:GetLevel() == 25 then
		local ability = npcBot:GetAbilityInSlot(7);
		if ability ~= nil and ability:GetName() == 'special_bonus_unique_doom_2' and ability:IsTrained() then
			canEatAncient = true;
		end
	end
	
	
	local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( 3 * nCastRange, true );
	if ( not npcBot:HasModifier("modifier_doom_bringer_devour") ) 
	then
		for _,npcCreep in pairs( tableNearbyEnemyCreeps )
		do
			if ( CanCastInfernalBladeOnTarget( npcCreep ) and 
				( ( not canEatAncient and not npcCreep:IsAncientCreep() ) or canEatAncient )
			) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcCreep;
			end
		end
	end	

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderScorchedEarth()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilitySE:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRadius = abilitySE:GetSpecialValueInt( "radius" );
	local nCastRange = 0;

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcBot, npcTarget ) < nRadius - 200 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end


	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderInfernalBlade()

	local npcBot = GetBot();

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
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
		end
	end
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastInfernalBladeOnTarget( npcTargetToKill ) and not enemyDisabled(npcTargetToKill) )
	then
		if ( npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcTargetToKill:GetHealth() and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < ( nCastRange + 200 ) )
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill;
		end
	end

	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() ) 
		then
			if ( CanCastInfernalBladeOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange + 200 and not enemyDisabled(npcTarget))
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderDoom()

	local npcBot = GetBot();

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
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then

		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( CanCastDoomOnTarget( npcEnemy ) )
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
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastDoomOnTarget( npcTargetToKill ) and not enemyDisabled(npcTargetToKill) )
	then
		if ( npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_PURE ) > npcTargetToKill:GetHealth() and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < ( nCastRange + 200 ) )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTargetToKill;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 800, false, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCastDoomOnTarget( npcEnemy )  and #tableNearbyAllyHeroes >= 2 ) 
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy;
				end
			end
		end
	end

	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() ) 
		then
			if ( CanCastDoomOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange + 200 and not enemyDisabled(npcTarget))
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end
