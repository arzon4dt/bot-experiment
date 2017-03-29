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

local castOODesire = 0;
local castFBDesire = 0;
local castVDDesire = 0;
local hauntTime = 0;

function AbilityUsageThink()

	local npcBot = GetBot();

	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced() ) then return end

	abilityOO = npcBot:GetAbilityByName( "spectre_reality" );
	abilityFB = npcBot:GetAbilityByName( "spectre_spectral_dagger" );
	abilityVD = npcBot:GetAbilityByName( "spectre_haunt" );
	hauntDuration = abilityVD:GetSpecialValueInt("duration");
	
	-- Consider using each ability
	castOODesire, castOOLocation = ConsiderOverwhelmingOdds();
	castFBDesire, castFBTarget = ConsiderFireblast();
	castVDDesire = ConsiderVendetta();

	if ( castOODesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityOO, castOOLocation );
		return;
	end
	
	if ( castFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		return;
	end
	
	if ( castVDDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityVD );
		hauntTime = DotaTime();
		return;
	end

	
end

function CanCastFireblastOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function ConsiderOverwhelmingOdds()

	local npcBot = GetBot();

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
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance(npcTarget, npcBot) > 550 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation( );
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderFireblast()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityFB:GetCastRange();
	local nRadius = abilityFB:GetSpecialValueInt("dagger_radius");
	local nDamage = abilityFB:GetSpecialValueInt("damage")

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastFireblastOnTarget( npcTargetToKill ) )
	then
		if ( npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcTargetToKill:GetHealth() and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < ( nCastRange + 200 ) )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTargetToKill;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCastFireblastOnTarget( npcEnemy ) ) 
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
		if ( npcTarget ~= nil and npcTargetToKill:IsHero() ) 
		then
			if ( CanCastFireblastOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange + 200 )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderVendetta()
	local npcBot = GetBot();

	if ( not abilityVD:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() )
	then
		if ( npcTargetToKill:GetActualIncomingDamage( 250, DAMAGE_TYPE_PHYSICAL ) > npcTargetToKill:GetHealth()  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK  or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK 
		 ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE;
end

