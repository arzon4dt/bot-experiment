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

local castDPDesire = 0;
local castPCDesire = 0;
local castSDDesire = 0;
local casthookDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityDP = npcBot:GetAbilityByName( "mirana_starfall" );
	abilityHook = npcBot:GetAbilityByName( "mirana_arrow" );
	abilityPC = npcBot:GetAbilityByName( "mirana_leap" );
	abilitySD = npcBot:GetAbilityByName( "mirana_invis" );

	-- Consider using each ability
	castDPDesire = ConsiderDarkPact();
	castHookDesire, castHookTarget = ConsiderHook();
	castPCDesire = ConsiderPounce();
	castSDDesire = ConsiderShadowDance();
	
	if ( castHookDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityHook, castHookTarget );
		return;
	end
	
	if ( castDPDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityDP );
		return;
	end
	
	if ( castPCDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityPC );
		return;
	end
	
	if ( castSDDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilitySD );
		return;
	end

end

function CanCastPounceOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function CanCastDarkPactOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function CanCastHookOnTarget( npcTarget )
	return not npcTarget:IsInvulnerable();
end

function enemyDisabled(npcTarget)
	if npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) then
		return true;
	end
	return false;
end


function ConsiderDarkPact()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityDP:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nCastRange = abilityDP:GetSpecialValueInt( "starfall_radius" );
	local nRadius = abilityDP:GetSpecialValueInt( "starfall_secondary_radius" );
	local nDamage = abilityDP:GetAbilityDamage();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and npcBot:GetHealth()/npcBot:GetMaxHealth() > 0.25 ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end

	-- If we're farming and can kill 3+ creeps with LSA
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 2000 );
		if ( locationAoE.count >= 3 and npcBot:GetMana()/npcBot:GetMaxMana() > 0.65 ) then
			return BOT_ACTION_DESIRE_LOW;
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and  GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end


function ConsiderHook()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityHook:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- If we want to cast priorities at all, bail
	--if ( castPhaseDesire > 0 or castCoilDesire > 50) then
	--	return BOT_ACTION_DESIRE_NONE;
	--end

	-- Get some of its values
	local nRadius = abilityHook:GetSpecialValueInt( "arrow_width" );
	local speed = abilityHook:GetSpecialValueInt( "arrow_speed" );
	local nDamage = abilityHook:GetAbilityDamage();
	local nCastRange = abilityHook:GetSpecialValueInt("arrow_range")
	local nCastPoint = abilityHook:GetCastPoint();

	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance(npcTarget, npcBot) < nCastRange ) 
		then
			local distance = GetUnitToUnitDistance(npcTarget, npcBot)
			local moveCon = npcTarget:GetMovementDirectionStability();
			local pLoc = npcTarget:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
			if moveCon == 0 then
				pLoc = npcTarget:GetLocation();
			end
			if not utils.AreEnemyCreepsBetweenMeAndLoc(pLoc, nRadius)  then
				return BOT_ACTION_DESIRE_MODERATE, pLoc;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderPounce()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityPC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nCastRange = abilityPC:GetSpecialValueInt( "leap_distance" );

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			local ancient = GetAncient(GetTeam());
			if npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and npcBot:IsFacingUnit(ancient, 10 )
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

		if ( npcTarget ~= nil and npcTarget:IsHero()) 
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( 800, false, BOT_MODE_NONE );
			if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes < 2 and GetUnitToUnitDistance( npcBot, npcTarget ) > nCastRange and npcBot:IsFacingUnit(npcTarget, 10))
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
		return BOT_ACTION_DESIRE_NONE;
	end

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 600, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) and npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.5 ) 
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
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( npcTarget ~= nil and npcTarget:IsHero() and #tableNearbyEnemyHeroes >= 2 and 
			GetUnitToUnitDistance( npcBot, npcTarget ) > 1000  and GetUnitToUnitDistance( npcBot, npcTarget ) < 2000 ) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end
