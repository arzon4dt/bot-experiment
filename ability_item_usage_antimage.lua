local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end

local castTWDesire = 0;
local castCHDesire = 0;
local abilityTW = "";
local abilityCH = "";

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end
	if abilityTW == "" then abilityTW = npcBot:GetAbilityByName( "antimage_blink" ); end
	if abilityCH == "" then abilityCH = npcBot:GetAbilityByName( "antimage_mana_void" ); end
	-- Consider using each ability
	castTWDesire, castTWLocation = ConsiderTimeWalk();
	castCHDesire, castCHTarget = ConsiderCorrosiveHaze();
	
	if ( castTWDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityTW, castTWLocation );
		return;
	end	
	if ( castCHDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityCH, castCHTarget );
		return;
	end
	
end

function CanCastCorrosiveHazeOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable() and not utils.HasForbiddenModifier(npcTarget) and 
	string.find(npcTarget:GetUnitName(), "hero");
end


function ConsiderTimeWalk()

	local npcBot = GetBot();
	
	-- Make sure it's castable
	if ( not abilityTW:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityTW:GetSpecialValueInt("blink_range");
	local nCastPoint = abilityTW:GetCastPoint( );

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 600, true, BOT_MODE_NONE );
		if ( npcBot:WasRecentlyDamagedByAnyHero(2.0) or npcBot:WasRecentlyDamagedByTower(2.0) or ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 1  ) )
		then
			--return BOT_ACTION_DESIRE_MODERATE, utils.GetTowardsFountainLocation( npcBot:GetLocation(), nCastRange )
			local location = npcBot:GetXUnitsTowardsLocation( GetAncient(GetTeam()):GetLocation(), nCastRange );
			return BOT_ACTION_DESIRE_MODERATE, location;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) > 300 and  GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange ) 
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( 800, false, BOT_MODE_NONE );
			if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes < 2 then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( 1.5*nCastPoint );
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderCorrosiveHaze()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityCH:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityCH:GetCastRange();
	local nDamagaPerHealth = abilityCH:GetSpecialValueFloat("mana_void_damage_per_mana");

	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
			local npcTarget = npcBot:GetTarget();
			if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastCorrosiveHazeOnTarget( npcTarget ) )
			then
				local EstDamage = nDamagaPerHealth * ( npcTarget:GetMaxMana() - npcTarget:GetMana() )
				local TPerMana = npcTarget:GetMana()/npcTarget:GetMaxMana();
				if npcTarget:GetActualIncomingDamage( EstDamage, DAMAGE_TYPE_MAGICAL ) > npcTarget:GetHealth() or TPerMana < 0.10
				then
					return BOT_ACTION_DESIRE_HIGH, npcTarget;
				end
			end
	end
	

	-- If we're in a teamfight, use it on the scariest enemy
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then

		local npcToKill = nil;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			local EstDamage = nDamagaPerHealth * ( npcEnemy:GetMaxMana() - npcEnemy:GetMana() )
			local TPerMana = npcEnemy:GetMana()/npcEnemy:GetMaxMana();
			if ( CanCastCorrosiveHazeOnTarget( npcEnemy ) and 
				( npcEnemy:GetActualIncomingDamage( EstDamage, DAMAGE_TYPE_MAGICAL ) > npcEnemy:GetHealth() or TPerMana < 0.10 ) and 
				GetUnitToUnitDistance( npcEnemy, npcBot ) < ( nCastRange + 200 ) 
				)
			then
				npcToKill = npcEnemy;
			end
		end

		if ( npcToKill ~= nil  )
		then
			return BOT_ACTION_DESIRE_HIGH, npcToKill;
		end
	end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		local EstDamage = nDamagaPerHealth * ( npcEnemy:GetMaxMana() - npcEnemy:GetMana() )
		local TPerMana = npcEnemy:GetMana()/npcEnemy:GetMaxMana();
		if ( CanCastCorrosiveHazeOnTarget( npcEnemy ) and npcEnemy:IsHero() and
			( npcEnemy:GetActualIncomingDamage( EstDamage, DAMAGE_TYPE_MAGICAL ) > npcEnemy:GetHealth()  or TPerMana < 0.10 or npcEnemy:IsChanneling() ) and 
			GetUnitToUnitDistance( npcEnemy, npcBot ) < ( nCastRange + 200 ) 
			)
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end
