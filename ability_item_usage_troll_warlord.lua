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
local castPC2Desire = 0;
local castSDDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityDP = npcBot:GetAbilityByName( "troll_warlord_berserkers_rage" );
	abilityPC = npcBot:GetAbilityByName( "troll_warlord_whirling_axes_melee" );
	abilityPC2 = npcBot:GetAbilityByName( "troll_warlord_whirling_axes_ranged" );
	abilitySD = npcBot:GetAbilityByName( "troll_warlord_battle_trance" );

	-- Consider using each ability
	castDPDesire = ConsiderDarkPact();
	castPCDesire = ConsiderPounce();
	castPC2Desire, castPC2Location = ConsiderPounce2();
	castSDDesire = ConsiderShadowDance();
	
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
	
	if ( castPC2Desire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityPC2, castPC2Location );
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

	local WARStatus = abilityPC2:IsHidden();

	-- Get some of its values
	local nCastRange = 500;

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	if ( npcBot:GetActiveMode() == BOT_MODE_LANING ) then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		local longestAR = 0;
		for _,enemy in pairs(tableNearbyEnemyHeroes)
		do
			local enemyAR = enemy:GetAttackRange();
			if enemyAR > longestAR then
				longestAR = enemyAR;
			end
		end
		if longestAR < 320 and not WARStatus then
			return BOT_ACTION_DESIRE_MODERATE;
		elseif longestAR > 320 and WARStatus then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_ROSHAN then
		if not WARStatus then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) and not WARStatus  ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end

	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 1 and WARStatus then
			return BOT_ACTION_DESIRE_MODERATE;
		elseif 	tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes < 1 and not WARStatus then
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
		if ( npcTarget ~= nil and npcTarget:IsHero()) 
		then
			local Dist = GetUnitToUnitDistance(npcTarget, npcBot);
			if Dist > nCastRange + 200 and not WARStatus then
				return BOT_ACTION_DESIRE_MODERATE;
			elseif Dist > nCastRange / 2 and Dist < nCastRange + 200 and WARStatus then
				return BOT_ACTION_DESIRE_MODERATE;
			elseif Dist < nCastRange / 2 and not WARStatus then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end


function ConsiderPounce()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityPC:IsFullyCastable() or abilityPC:IsHidden() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRadius = abilityPC:GetSpecialValueInt( "max_range" );

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT ) 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps ( nRadius, true );
		if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3 then
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
			if ( CanCastPounceOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nRadius )
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderPounce2()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityPC2:IsFullyCastable() or abilityPC2:IsHidden() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nCastRange = abilityPC2:GetCastRange(  );
	local nCastPoint = abilityPC2:GetCastPoint(  );

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
			if ( CanCastPounceOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < (nCastRange - 200) )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nCastPoint);
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
	
	local nAttackRange = npcBot:GetAttackRange();
	
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
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcBot, npcTarget ) < nAttackRange  ) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end
