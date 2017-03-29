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

local castFSDesire = 0;
local castPMDesire = 0;
local castDRDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityFS = npcBot:GetAbilityByName( "abyssal_underlord_firestorm" );
	abilityPM = npcBot:GetAbilityByName( "abyssal_underlord_pit_of_malice" );
	abilityDR = npcBot:GetAbilityByName( "abyssal_underlord_dark_rift" );
	

	-- Consider using each ability
	castFSDesire, castFSLocation = ConsiderFireStorm();
	castPMDesire, castPMLocation = ConsiderPitOfMalice();
	castDRDesire, castDRLocation = ConsiderDarkRift();
	
	if ( castDRDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityDR, castDRLocation );
		return;
	end
	
	if ( castFSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityFS, castFSLocation );
		return;
	end
	
	if ( castPMDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityPM, castPMLocation );
		return;
	end
	

end

function CanCastFireStormOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastPitOfMaliceOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end


function ConsiderFireStorm()

	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilityFS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nRadius = abilityFS:GetSpecialValueInt( "radius" );
	local nCastRange = abilityFS:GetCastRange();
	local nCastPoint = abilityFS:GetCastPoint( );
	local nDamage = 6 * abilityFS:GetSpecialValueInt("wave_damage");

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastFireStormOnTarget( npcTargetToKill ) )
	then
		if ( npcTargetToKill:IsHero() and  npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcTargetToKill:GetHealth() and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < ( nCastRange - 300 ) )
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill:GetExtrapolatedLocation( nCastPoint );
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 10000 );
		if ( locationAoE.count >= 2 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.8 ) 
		then
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange - 200 and CanCastFireStormOnTarget( npcTarget ) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderPitOfMalice()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityPM:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilityPM:GetSpecialValueInt( "radius" );
	local nCastRange = abilityPM:GetCastRange();
	local nCastPoint = abilityPM:GetCastPoint( );
	local nDamage = 1000

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastPitOfMaliceOnTarget( npcTargetToKill ) )
	then
		if ( npcTargetToKill:IsHero() and  npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcTargetToKill:GetHealth() and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < ( nCastRange - 200 ) )
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill:GetExtrapolatedLocation( nCastPoint );
		end
	end

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 1000 );

		if ( locationAoE.count >= 2 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.8 ) 
		then
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange - 200 and CanCastPitOfMaliceOnTarget( npcTarget )  ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderDarkRift()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityDR:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	if npcBot:DistanceFromFountain() < 3000 then
		return BOT_ACTION_DESIRE_NONE, 0;
	end	
		
	-- Get some of its values
	local nRadius = abilityDR:GetSpecialValueInt( "radius" );

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				local RB = Vector(-7200,-6666)
				local DB = Vector(7137,6548)
				local location = Vector(0, 0)
				if GetOpposingTeam( ) == TEAM_DIRE then
					location = RB;
				end
				if GetOpposingTeam( ) == TEAM_RADIANT then
					location = DB;
				end
				return BOT_ACTION_DESIRE_LOW, location;
			end
		end
	end
	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
	     npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK ) 
	then
		local npcTarget = npcBot:GetTarget();

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) > 2500 ) 
		then
			local tableNearbyEnemyCreeps = npcTarget:GetNearbyCreeps( 800, true );
			local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			if tableNearbyEnemyCreeps ~= nil and tableNearbyAllyHeroes ~= nil and #tableNearbyEnemyCreeps >= 2 and #tableNearbyAllyHeroes >= 1 then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
			end	
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

