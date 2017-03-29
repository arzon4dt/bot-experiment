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

local castDCDesire = 0;
local castPCDesire = 0;
local castSDDesire = 0;

local abilityDC = "";
local abilityPC = "";
local abilitySD = "";

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	if abilityDC == "" then abilityDC = npcBot:GetAbilityByName( "weaver_the_swarm" ); end
	if abilityPC == "" then abilityPC = npcBot:GetAbilityByName( "weaver_shukuchi" ); end
	if abilitySD == "" then abilitySD = npcBot:GetAbilityByName( "weaver_time_lapse" ); end

	-- Consider using each ability
	castDCDesire, castDCLocation = ConsiderDecay();
	castPCDesire = ConsiderPounce();
	castSDDesire, castSDTarget = ConsiderShadowDance();
	
	if ( castDCDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityDC, castDCLocation );
		return;
	end
	
	if ( castPCDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityPC );
		return;
	end
	
	if ( castSDDesire > 0 ) 
	then
		if castSDTarget == "-1" then
			npcBot:Action_UseAbility( abilitySD );
		else
			npcBot:Action_UseAbilityOnEntity( abilitySD, castSDTarget );
		end
		return;
	end

end

function CanCastDecayOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end


function ConsiderDecay()

	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilityDC:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nRadius = abilityDC:GetSpecialValueInt( "spawn_radius" );
	local nCastRange = 1000;
	local nCastPoint = abilityDC:GetCastPoint( );

	--------------------------------------
	-- Mode based usage
	--------------------------------------
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
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 4 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.65 ) 
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange and CanCastDecayOnTarget( npcTarget ) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end



function ConsiderPounce()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityPC:IsFullyCastable() or castSDDesire > 0 ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local nAttackRange = npcBot:GetAttackRange(); 
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( npcBot:WasRecentlyDamagedByAnyHero(2.0) or npcBot:WasRecentlyDamagedByTower(2.0) or ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 1  ) )
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

		if ( npcTarget ~= nil and npcTarget:IsHero() ) 
		then
			local dist = GetUnitToUnitDistance( npcBot, npcTarget ); 
			if ( dist > nAttackRange + 200 and dist < 2000  )
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderShadowDance()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilitySD:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 and npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.15 and abilityPC:GetCooldownTimeRemaining() < 3 then
			return BOT_ACTION_DESIRE_MODERATE, "-1";
		end
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.25 ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, "-1";
			end
		end
	end

	if npcBot:HasScepter() then
		local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
		for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
			if myFriend:GetActiveMode() == BOT_MODE_RETREAT and myFriend:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH and
				myFriend:WasRecentlyDamagedByAnyHero(2.0) and myFriend:GetHealth() / myFriend:GetMaxHealth() < 0.25
			then
				return BOT_ACTION_DESIRE_MODERATE, myFriend;
			end
		end	
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end
