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

local castISDesire = 0;
local castSGDesire = 0;
local castVCDesire = 0;
local castWRDesire = 0;
local abilityIS = "";
local abilitySG = "";
local abilityVC = "";
local abilityWR = "";

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	if abilityVC == "" then abilityVC = npcBot:GetAbilityByName( "dark_seer_vacuum" ); end
	if abilityIS == "" then abilityIS = npcBot:GetAbilityByName( "dark_seer_ion_shell" ); end
	if abilitySG == "" then abilitySG = npcBot:GetAbilityByName( "dark_seer_surge" ); end
	if abilityWR == "" then abilityWR = npcBot:GetAbilityByName( "dark_seer_wall_of_replica" ); end

	-- Consider using each ability
	castVCDesire, castVCLocation = ConsiderVacuum();
	castISDesire, castISTarget = ConsiderIonShell();
	castSGDesire, castSGTarget = ConsiderSurge();
	castWRDesire, castWRLocation = ConsiderWallOfReplica();
	
	if ( castWRDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityWR, castWRLocation );
		return;
	end
	
	if ( castVCDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityVC, castVCLocation );
		return;
	end
	
	if ( castISDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityIS, castISTarget );
		return;
	end
	
	if ( castSGDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilitySG, castSGTarget );
		return;
	end

end

function CanCastIonShellOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end
function CanCastSurgeOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end

function ConsiderVacuum()

	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilityVC:IsFullyCastable() or abilityVC:GetLevel() < 2 ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if castWRDesire > 0 then
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilityVC:GetSpecialValueInt( "radius" );
	local nCastRange = abilityVC:GetCastRange();
	local nCastPoint = abilityVC:GetCastPoint( );
	local nDamage = abilityVC:GetSpecialValueInt( "damage" );

	--------------------------------------
	-- Mode based usage
	--------------------------------------

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
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange  ) 
		then
			local targetAllies = npcTarget:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			if targetAllies ~= nil and #targetAllies >= 2 then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nCastPoint);
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange  ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderIonShell()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityIS:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityIS:GetCastRange();

	-- If we're pushing or defending a lane
	if ( npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
			if npcBot:GetMana() / npcBot:GetMaxMana() >= 0.65 then
				local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
				for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
					if ( GetUnitToUnitDistance( myFriend, npcBot  ) < nCastRange and 
						not myFriend:HasModifier("modifier_dark_seer_ion_shell") and
						myFriend:GetAttackRange() < 320
						) 
					then
						return BOT_ACTION_DESIRE_MODERATE, myFriend;
					end
				end	
				if not npcBot:HasModifier("modifier_dark_seer_ion_shell") then
					return BOT_ACTION_DESIRE_MODERATE, npcBot;
				end
			end
	end
	
	-- If we're pushing or defending a lane
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT  ) 
	then
		if npcBot:GetMana() / npcBot:GetMaxMana() >= 0.65 then
			local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
			for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
				if ( GetUnitToUnitDistance( myFriend, npcBot  ) < nCastRange and 
					not myFriend:HasModifier("modifier_dark_seer_ion_shell") and
					myFriend:GetAttackRange() < 320
					) 
				then
					return BOT_ACTION_DESIRE_MODERATE, myFriend;
				end
			end	
			local tableNearbyFriendlyCreeps = npcBot:GetNearbyLaneCreeps( nCastRange, false );
			for _,myCreeps in pairs(tableNearbyFriendlyCreeps) do
				if myCreeps:GetHealth() / myCreeps:GetMaxHealth() >= 0.85 and 
					myCreeps:GetAttackRange() < 320 and 
					not myCreeps:HasModifier("modifier_dark_seer_ion_shell") 
				then
					return BOT_ACTION_DESIRE_MODERATE, myCreeps;
				end
			end
			if not npcBot:HasModifier("modifier_dark_seer_ion_shell") then
				return BOT_ACTION_DESIRE_MODERATE, npcBot;
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
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance(npcTarget, npcBot) <= 1000 ) 
		then
			local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
			for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
				if ( GetUnitToUnitDistance( myFriend, npcBot  ) < nCastRange and 
					not myFriend:HasModifier("modifier_dark_seer_ion_shell")   and 
					myFriend:GetAttackRange() < 320 )
				then
					return BOT_ACTION_DESIRE_MODERATE, myFriend;
				end
			end	
			if not npcBot:HasModifier("modifier_dark_seer_ion_shell") then
				return BOT_ACTION_DESIRE_MODERATE, npcBot;
			end
		end	
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderSurge()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilitySG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilitySG:GetCastRange();

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcBot;
			end
		end
	end
	
	local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
	for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
		if myFriend:GetActiveMode() == BOT_MODE_RETREAT and myFriend:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH and
			myFriend:WasRecentlyDamagedByAnyHero(2.0)
		then
			return BOT_ACTION_DESIRE_MODERATE, myFriend;
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
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance(npcTarget, npcBot) <= 1000 ) 
		then
			local ClosestDist = GetUnitToUnitDistance(npcTarget, npcBot);
			local ClosestBot = npcBot; 
			for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
				local dist = GetUnitToUnitDistance(npcTarget, myFriend);
				if dist < ClosestDist and dist < nCastRange then
					ClosestDist = dist;
					ClosestBot = myFriend;
				end
			end	
			return BOT_ACTION_DESIRE_MODERATE, ClosestBot;
		end	
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderWallOfReplica()

	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilityWR:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	

	-- Get some of its values
	local nRadius = abilityVC:GetSpecialValueInt( "radius" );
	local nCastRange = abilityWR:GetCastRange();
	local nCastPoint = abilityWR:GetCastPoint( );

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange  ) 
		then
			local targetAllies = npcTarget:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			if targetAllies ~= nil and #targetAllies >= 2 then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nCastPoint);
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end