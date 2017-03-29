--require(GetScriptDirectory() ..  "/ability_item_usage_generic")
local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
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

local castIVDesire = 0;
local castBSDesire = 0;
local castLBDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityIV = npcBot:GetAbilityByName( "huskar_inner_vitality" );
	abilityBS = npcBot:GetAbilityByName( "huskar_burning_spear" );
	abilityLB = npcBot:GetAbilityByName( "huskar_life_break" );

	-- Consider using each ability
	castIVDesire, castIVTarget = ConsiderInnerVitality();
	castBSDesire, castBSTarget = ConsiderBurningSpear();
	castLBDesire, castLBTarget = ConsiderLifeBreak();
	

	if ( castLBDesire > castIVDesire and castLBDesire > castBSDesire ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityLB, castLBTarget );
		return;
	end

	if ( castIVDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityIV, castIVTarget );
		return;
	end
	
	if ( castBSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityBS, castBSTarget );
		return;
	end

end

function CanCastInnerVitalityOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastBurningSpearOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastLifeBreakOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end
function enemyDisabled(npcTarget)
	if npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) then
		return true;
	end
	return false;
end

function ConsiderInnerVitality()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityIV:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityIV:GetCastRange();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 400, true, BOT_MODE_NONE );
			if ( tableNearbyEnemyHeroes ~= nil ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcBot;
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
		if ( npcTarget ~= nil ) 
		then
			if (GetUnitToUnitDistance( npcBot, npcTarget ) < 400)
			then
				return BOT_ACTION_DESIRE_HIGH, npcBot;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function ConsiderBurningSpear()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityBS:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	
	-- Get some of its values
	local nCastRange = abilityBS:GetCastRange();
	local nDamage = abilityBS:GetAbilityDamage();
	local nRadius = 0;
	local attackRange = npcBot:GetAttackRange();
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and CanCastBurningSpearOnTarget( npcTargetToKill ) and GetUnitToUnitDistance(npcTargetToKill, npcBot) <= attackRange )
	then
		if ( npcTargetToKill:GetActualIncomingDamage( (8*nDamage), DAMAGE_TYPE_MAGICAL ) > npcTargetToKill:GetHealth() )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTargetToKill;
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
		if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastBurningSpearOnTarget( npcTarget ) and GetUnitToUnitDistance(npcTarget, npcBot) <= attackRange ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderLifeBreak()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityLB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityLB:GetCastRange();
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and CanCastLifeBreakOnTarget( npcTargetToKill ) and not enemyDisabled(npcTargetToKill) )
	then
		if ( (npcTargetToKill:GetHealth() / npcTargetToKill:GetMaxHealth()) < 0.5 and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < ( nCastRange + 200 ) )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTargetToKill;
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

		if ( npcTarget ~= nil and CanCastLifeBreakOnTarget( npcTarget ) and not enemyDisabled(npcTarget)) 
		then
			if ( GetUnitToUnitDistance( npcTarget, npcBot ) < ( nCastRange + 200 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
