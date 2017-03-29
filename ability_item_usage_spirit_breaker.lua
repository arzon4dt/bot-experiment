--require(GetScriptDirectory() ..  "/ability_item_usage_generic")
ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local inspect = require(GetScriptDirectory() ..  "/inspect")
local enemyStatus = require(GetScriptDirectory() .. "/enemy_status" )

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end

local castCDDesire = 0;
local castEHDesire = 0;
local castNSDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:HasModifier("modifier_spirit_breaker_charge_of_darkness") or npcBot:IsChanneling() or npcBot:IsSilenced() ) then return end;

	abilityCD = npcBot:GetAbilityByName( "spirit_breaker_charge_of_darkness" );
	abilityEH = npcBot:GetAbilityByName( "spirit_breaker_empowering_haste" );
	abilityNS = npcBot:GetAbilityByName( "spirit_breaker_nether_strike" );

	castEHDesire = ConsiderEmpoweringHaste();
	castCDDesire, castCDTarget = ConsiderCharge();
	castNSDesire, castNSTarget = ConsiderNetherStrike();

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
		npcBot:Action_ClearActions(false);
		npcBot:Action_UseAbilityOnEntity( abilityCD, castCDTarget );
		return;
	end
	
end

function CanCastNetherStrikeOnTarget( npcTarget )
	return npcTarget:CanBeSeen()  and not npcTarget:IsInvulnerable();
end

function CanCastChargeOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function IsDisabled(npcTarget)
	if npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) or npcTarget:IsSilenced()  
	then
		return true;
	end
	return false;
end

function ConsiderEmpoweringHaste()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityEH:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local AttackRange = npcBot:GetAttackRange();
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
		if ( npcBot:WasRecentlyDamagedByAnyHero(2.0) or npcBot:WasRecentlyDamagedByTower(2.0) or ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1  ) )
		then
			return BOT_ACTION_DESIRE_HIGH;
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
		local dist = GetUnitToUnitDistance( npcBot, npcTarget );
		if ( npcTarget ~= nil and npcTarget:IsHero() and dist > 2*AttackRange )
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderCharge()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityCD:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = npcBot:GetAttackRange() + 150;
	
	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and 
			CanCastChargeOnTarget( npcTarget ) and 
			--GetUnitToUnitDistance( npcTarget, npcBot ) <= nCastRange and
			not IsDisabled(npcTarget)) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderNetherStrike()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityNS:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityNS:GetCastRange();
	local nDamage = abilityNS:GetAbilityDamage();
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( CanCastNetherStrikeOnTarget(npcEnemy) and 
			( npcEnemy:IsChanneling() or npcEnemy:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcEnemy:GetHealth() ) and 
			 GetUnitToUnitDistance( npcEnemy, npcBot ) < nCastRange + 200 )
		then
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
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
		if ( npcTarget ~= nil and npcTarget:IsHero() and 
			CanCastNetherStrikeOnTarget( npcTarget ) and 
			GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange + 200 and
			not IsDisabled(npcTarget)) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end
