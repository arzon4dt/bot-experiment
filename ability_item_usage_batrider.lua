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

local castSNDesire = 0;
local castFFDesire = 0;
local castFBDesire = 0;
local castFLDesire = 0;

local abilitySN = "";
local abilityFB = "";
local abilityFF = "";
local abilityFL = "";

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	if abilitySN == "" then abilitySN = npcBot:GetAbilityByName( "batrider_sticky_napalm" ); end
	if abilityFB == "" then abilityFB = npcBot:GetAbilityByName( "batrider_flamebreak" ); end
	if abilityFF == "" then abilityFF = npcBot:GetAbilityByName( "batrider_firefly" ); end
	if abilityFL == "" then abilityFL = npcBot:GetAbilityByName( "batrider_flaming_lasso" ); end

	-- Consider using each ability
	castSNDesire, castDCLocation = ConsiderStickyNapalm();
	castFBDesire, castFBLocation = ConsiderFlameBreak();
	castFFDesire = ConsiderFireFly();
	castFLDesire, castFLTarget = ConsiderFlamingLasso();
	
	if ( castFLDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFL, castFLTarget );
		return;
	end
	
	if ( castFFDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityFF );
		return;
	end

	if ( castSNDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilitySN, castDCLocation );
		return;
	end
	
	if ( castFBDesire > 0 ) 
	then
		
		npcBot:Action_UseAbilityOnLocation( abilityFB, castFBLocation );
		return;
	end	
	

end


function CanCastStickyNapalmOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function CanCastFireFlyOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function CanCastFlamingLasooOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable() and  
	string.find(npcTarget:GetUnitName(), "hero");
end


function ConsiderStickyNapalm()

	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilitySN:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nRadius = abilitySN:GetSpecialValueInt( "radius" );
	local nCastRange = abilitySN:GetCastRange();
	local nCastPoint = abilitySN:GetCastPoint( );

	--------------------------------------
	-- Mode based usage
	---------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( npcBot:GetActiveMode() == BOT_MODE_LANING or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 3 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.75 ) 
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange and CanCastStickyNapalmOnTarget( npcTarget ) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderFlameBreak()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilityFB:GetSpecialValueInt("explosion_radius");
	local nSpeed = abilityFB:GetSpecialValueInt("speed");
	local nCastRange = abilityFB:GetCastRange();
	local nCastPoint = abilityFB:GetCastPoint();

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and 
		npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH  ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) )
			then
				if GetUnitToUnitDistance(npcEnemy, npcBot) < nRadius then
					return BOT_ACTION_DESIRE_LOW, npcBot:GetLocation()
				else
					return BOT_ACTION_DESIRE_LOW, npcEnemy:GetExtrapolatedLocation(nCastPoint)
				end
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil  and npcTarget:IsHero() and CanCastStickyNapalmOnTarget(npcTarget) and GetUnitToUnitDistance( npcTarget, npcBot ) < 1000 ) 
		then
			local nDelay = ( GetUnitToUnitDistance( npcTarget, npcBot ) / nSpeed ) + nCastPoint
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nDelay);
		end
	end
	
--
	return BOT_ACTION_DESIRE_NONE;
end



function ConsiderFireFly()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityFF:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = abilityFF:GetSpecialValueInt( "radius" );
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 4*nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 4*nRadius, true, BOT_MODE_NONE  );
		if ( #tableNearbyEnemyHeroes >= 2 )
		then
			return BOT_ACTION_DESIRE_MODERATE;
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcBot, npcTarget ) < 3*nRadius  ) 
		then
			if ( CanCastFireFlyOnTarget( npcTarget ) )
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderFlamingLasso()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityFL:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityFL:GetCastRange();
	
	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastFlamingLasooOnTarget( npcTarget ) and GetUnitToUnitDistance(npcTarget, npcBot) < nCastRange + 200 )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
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
			if CanCastFlamingLasooOnTarget( npcEnemy ) and GetUnitToUnitDistance( npcEnemy, npcBot ) < ( nCastRange + 200 ) 
			then
				npcToKill = npcEnemy;
			end
		end
		if ( npcToKill ~= nil  )
		then
			return BOT_ACTION_DESIRE_HIGH, npcToKill;
		end
	end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if CanCastFlamingLasooOnTarget( npcEnemy ) and npcEnemy:IsHero() and npcEnemy:IsChanneling()
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end
