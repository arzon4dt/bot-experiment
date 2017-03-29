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
local castOGDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityOO = npcBot:GetAbilityByName( "riki_smoke_screen" );
	abilityFB = npcBot:GetAbilityByName( "riki_blink_strike" );
	abilityOG = npcBot:GetAbilityByName( "riki_tricks_of_the_trade" );

	-- Consider using each ability
	castOODesire, castOOLocation = ConsiderOverwhelmingOdds();
	castFBDesire, castFBTarget = ConsiderFireblast();
	castOGDesire, castOGTarget = ConsiderOvergrowth();

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
	
	if ( castOGDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityOG );
		return;
	end

	
end

function CanCastOverWhelmingOddsOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastFireblastOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastOvergrowthOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end


function ConsiderOverwhelmingOdds()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityOO:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nRadius = abilityOO:GetSpecialValueInt( "radius" );
	local nCastRange = abilityOO:GetCastRange();
	local nCastPoint = abilityOO:GetCastPoint( );

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + nRadius ,true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and GetUnitToUnitDistance(npcEnemy, npcBot) < nCastRange ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
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
		local distance = GetUnitToUnitDistance(npcTarget, npcBot);
		if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastOverWhelmingOddsOnTarget( npcTarget ) and distance < ( nCastRange + nRadius )  ) 
		then
			--return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation( );
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
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
	local nDamage = npcBot:GetAttackDamage() + abilityFB:GetSpecialValueInt("bonus_damage");

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local npcTarget = npcBot:GetTarget();
	if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastFireblastOnTarget( npcTarget ) )
	then
		if ( npcTarget:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_PHYSICAL ) > npcTarget:GetHealth() and GetUnitToUnitDistance( npcTarget, npcBot ) < ( nCastRange + 200 ) )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 then
			local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
			local tableNearbyAlliedCreeps = npcBot:GetNearbyLaneCreeps ( nCastRange, false );
			local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps ( nCastRange, true );
				for _,npcAllied in pairs( tableNearbyAlliedHeroes  )
				do
					if ( npcAllied:GetUnitName() ~= npcBot:GetUnitName() and GetUnitToUnitDistance( npcAllied, npcBot ) < nCastRange and CanCastFireblastOnTarget(npcAllied) ) 
					then
						return BOT_ACTION_DESIRE_HIGH, npcAllied;
					end
				end
			
				for _,npcACreep in pairs( tableNearbyAlliedCreeps  )
				do
					if ( GetUnitToUnitDistance( npcACreep, npcBot ) < nCastRange and CanCastFireblastOnTarget(npcACreep) ) 
					then
						return BOT_ACTION_DESIRE_HIGH, npcACreep;
					end
				end
		
				for _,npcECreep in pairs( tableNearbyEnemyCreeps  )
				do
					if ( GetUnitToUnitDistance( npcECreep, npcBot ) < nCastRange and CanCastFireblastOnTarget(npcECreep)  ) 
					then
						return BOT_ACTION_DESIRE_HIGH, npcECreep;
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
		if ( npcTarget ~= nil  and npcTarget:IsHero() ) 
		then
			if ( CanCastFireblastOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange  )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderOvergrowth()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityOG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if castFBDesire > 0 or castOODesire > 0 then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = abilityOG:GetSpecialValueInt( "range" );
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
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

		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcBot, npcTarget ) < nRadius  ) 
		then
			if ( CanCastOvergrowthOnTarget( npcTarget ) )
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end
