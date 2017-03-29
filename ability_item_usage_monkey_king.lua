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

local castBSDesire = 0;
local castTDDesire = 0;
local castPSDesire = 0;
local castWCDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityBS = npcBot:GetAbilityByName( "monkey_king_boundless_strike" );
	abilityTD = npcBot:GetAbilityByName( "monkey_king_tree_dance" );
	abilityPS = npcBot:GetAbilityByName( "monkey_king_primal_spring" );
	abilityWC = npcBot:GetAbilityByName( "monkey_king_wukongs_command" );
	
	-- Consider using each ability
	castWCDesire, castWCLocation = ConsiderWukongCommand();
	castBSDesire, castBSLocation = ConsiderBoundlessStrike();
	castTDDesire, castTDTarget = ConsiderTreeDance();
	castPSDesire, castPSLocation = ConsiderPrimalSpring();

	if ( castWCDesire > 0 ) 
	then
		
		npcBot:Action_UseAbilityOnLocation( abilityWC, castWCLocation );
		return;
	end
	
	if ( castBSDesire > 0 ) 
	then
		
		npcBot:Action_UseAbilityOnLocation( abilityBS, castBSLocation );
		return;
	end
	
	if ( castTDDesire > 0 ) 
	then
		
		npcBot:Action_UseAbilityOnTree( abilityTD, castTDTarget );
		return;
	end
		
	if ( castPSDesire > 0 ) 
	then
		
		npcBot:Action_UseAbilityOnLocation( abilityPS, castPSLocation );
		return;
	end	

end

function CanCastBoundlessStrikeOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function enemyDisabled(npcTarget)
	if npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) then
		return true;
	end
	return false;
end

function ConsiderBoundlessStrike()

	local npcBot = GetBot();
	
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilityBS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
--
	-- If we want to cast Laguna Blade at all, bail
	--[[if ( castPRDesire > 0 ) 
	then
		return BOT_ACTION_DESIRE_NONE, 0;
	end]]--

	-- Get some of its values
	local nCastRange = abilityBS:GetCastRange();
	local nCastPoint = abilityBS:GetCastPoint( );

	
	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			--return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation( nCastPoint );
		end
	end

	if npcBot:HasModifier('modifier_monkey_king_jingu_mastery') then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange , true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( GetUnitToUnitDistance( npcEnemy, npcBot ) < nCastRange  - (nCastRange / 3)  ) 
			then
				--return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation( );
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation( nCastPoint );
			end
		end
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
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and GetUnitToUnitDistance( npcEnemy, npcBot ) < nCastRange ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation( );
			end
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 1 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( GetUnitToUnitDistance(npcEnemy, npcBot) < nCastRange ) 
			then
				--return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation( nCastPoint );
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

		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange  - (nCastRange / 3) ) 
		then
			if ( CanCastBoundlessStrikeOnTarget( npcTarget ) )
			then
				--return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
			end
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderTreeDance()
	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilityTD:IsFullyCastable() or not abilityPS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityTD:GetCastRange();
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	if tableNearbyEnemyHeroes == nil then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if ( not abilityPS:IsFullyCastable() and not abilityPS:IsHidden() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 1 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( GetUnitToUnitDistance(npcEnemy, npcBot) < nCastRange ) 
			then
				local tableNearbyTrees = npcBot:GetNearbyTrees( nCastRange );
				if #tableNearbyTrees > 0 then
					return BOT_ACTION_DESIRE_MODERATE, tableNearbyTrees[1];
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

		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange  - (nCastRange / 3) ) 
		then
			local tableNearbyTrees = npcBot:GetNearbyTrees( nCastRange );
			if #tableNearbyTrees > 0 then
				return BOT_ACTION_DESIRE_MODERATE, tableNearbyTrees[1];
			end
		end
	end 
	
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderPrimalSpring()

	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	
	--local nt = npcBot:GetNearbyTrees(20)
	--print(#nt)
	
	if ( not abilityPS:IsFullyCastable() or abilityPS:IsHidden() or abilityTD:GetCooldownTimeRemaining() > 1.4 ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	
	-- Get some of its values
	local nCastRange = abilityPS:GetSpecialValueInt("max_distance");
	local nCastPoint = abilityPS:GetChannelTime( );
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	if tableNearbyEnemyHeroes == nil then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 1 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( GetUnitToUnitDistance(npcEnemy, npcBot) < nCastRange ) 
			then
				if enemyDisabled(npcEnemy) then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
				else
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation( nCastPoint );
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

		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange ) 
		then
			if enemyDisabled(npcTarget) then
				return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation( );
			else
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
			end
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderWukongCommand()
	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilityWC:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
--
	-- Get some of its values
	local nCastRange = abilityWC:GetSpecialValueInt("cast_range");
	local nRadius = abilityWC:GetSpecialValueInt("second_radius");

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 10000 );

		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
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
		
		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange ) 
		then
			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
			if #tableNearbyEnemyHeroes >= 2 then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
			end
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end