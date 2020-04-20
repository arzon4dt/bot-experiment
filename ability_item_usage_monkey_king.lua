if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local mutil = require(GetScriptDirectory() ..  "/MyUtility")

if GetBot():IsInvulnerable() then
	return;
end

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end
function ItemUsageThink()
	ability_item_usage_generic.ItemUsageThink();
end

local castBSDesire = 0;
local castTDDesire = 0;
local castPSDesire = 0;
local castPSEDesire = 0;
local castMCDesire = 0;
local castUTDesire = 0;
local castWCDesire = 0;

local abilityBS = nil;
local abilityTD = nil;
local abilityPS = nil;
local abilityPSE = nil;
local abilityMC = nil;
local abilityUT = nil;
local abilityWC = nil;

local PSLoc = {0, 0, 0};
local Ancient = GetAncient(GetTeam());

local npcBot = nil;
local WCLoc = nil;
local castWCTime = -90;

function AbilityUsageThink()

	

	if npcBot == nil then npcBot = GetBot(); end
	
	if WCLoc ~= nil and DotaTime() > castWCTime +14 then
		WCLoc = nil;
	end
	-- local mod = npcBot:GetModifierList();
	-- for k,v in pairs(mod) do
		-- print(tostring(k)..","..tostring(v));
	-- end
	
	if abilityPSE == nil then abilityPSE = npcBot:GetAbilityByName( "monkey_king_primal_spring_early" ) end
	
	castPSEDesire = ConsiderPrimalSpringEarly();
	
	if ( castPSEDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityPSE );
		return;
	end	
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end

	if abilityBS == nil then abilityBS = npcBot:GetAbilityByName( "monkey_king_boundless_strike" ) end
	if abilityTD == nil then abilityTD = npcBot:GetAbilityByName( "monkey_king_tree_dance" ) end
	if abilityPS == nil then abilityPS = npcBot:GetAbilityByName( "monkey_king_primal_spring" ) end
	if abilityMC == nil then abilityMC = npcBot:GetAbilityByName( "monkey_king_mischief" ) end
	if abilityUT == nil then abilityUT = npcBot:GetAbilityByName( "monkey_king_untransform" ) end
	if abilityWC == nil then abilityWC = npcBot:GetAbilityByName( "monkey_king_wukongs_command" ) end
	
	-- Consider using each ability
	castWCDesire, castWCLocation = ConsiderWukongCommand();
	castBSDesire, castBSLocation = ConsiderBoundlessStrike();
	castTDDesire, castTDTarget = ConsiderTreeDance();
	castMCDesire                 = ConsiderMischief();
	castUTDesire                 = ConsiderUntransform();
	castPSDesire, castPSLocation = ConsiderPrimalSpring();
	
	if ( castMCDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityMC );
		return;
	end
	
	if ( castUTDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityUT );
		return;
	end
	
	if ( castWCDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityWC, castWCLocation );
		WCLoc = castWCLocation;
		castWCTime = DotaTime();
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
		PSLoc = castPSLocation;
		npcBot:Action_UseAbilityOnLocation( abilityPS, castPSLocation );
		return;
	end	

end

function GetFurthestTree(trees)
	if Ancient == nil then return nil end; 
	local furthest = nil;
	local fDist = 10000;
	for _,tree in pairs(trees)
	do
		local dist = GetUnitToLocationDistance(Ancient, GetTreeLocation(tree));
		if dist < fDist then
			furthest = tree;
			fDist = dist;
		end
	end
	return furthest;
end

function ConsiderBoundlessStrike()

	-- Make sure it's castable
	if ( not abilityBS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

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
			if (mutil.CanCastOnNonMagicImmune(npcEnemy) and mutil.IsInRange(npcEnemy, npcBot, nCastRange-200)) 
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
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation( );
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, 200, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if (  mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange-200) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderTreeDance()

	-- Make sure it's castable
	if ( not abilityTD:IsFullyCastable() or not abilityPS:IsFullyCastable() or npcBot:IsRooted() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityTD:GetCastRange();
	local nRadius = abilityWC:GetSpecialValueInt("second_radius");
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	if tableNearbyEnemyHeroes == nil then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if ( not abilityPS:IsFullyCastable() and not abilityPS:IsHidden() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if mutil.IsRetreating(npcBot) and abilityPS:IsFullyCastable() and npcBot:DistanceFromFountain() > 1000 and #tableNearbyEnemyHeroes >= 1
	then
		local tableNearbyTrees = npcBot:GetNearbyTrees( nCastRange );
		local furthest = GetFurthestTree(tableNearbyTrees);
		if furthest ~= nil then
			return BOT_ACTION_DESIRE_MODERATE, furthest;
		end
	end

	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) 
			and mutil.CanCastOnNonMagicImmune(npcTarget) 
			and mutil.IsInRange(npcTarget, npcBot, nCastRange) ) 
		then
			local tableNearbyTrees = npcTarget:GetNearbyTrees( nCastRange );
			if tableNearbyTrees ~= nil 
				and #tableNearbyTrees >= 1 
			then
				if npcBot:HasModifier('modifier_monkey_king_fur_army_bonus_damage') == false 
					or WCLoc == nil
					or ( npcBot:HasModifier('modifier_monkey_king_fur_army_bonus_damage') == true and utils.GetDistance(GetTreeLocation(tableNearbyTrees[1]), WCLoc) < 0.90*nRadius )
				then	
					return BOT_ACTION_DESIRE_MODERATE, tableNearbyTrees[1];
				end
			end
		end
	end 
	
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderPrimalSpring()
	
	if ( not abilityPS:IsFullyCastable() or abilityPS:IsHidden() or abilityPS:IsActivated() == false ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityPS:GetSpecialValueInt("max_distance");
	local nRadius = abilityPS:GetSpecialValueInt("impact_radius");
	local nCastPoint = abilityPS:GetChannelTime( );
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	if tableNearbyEnemyHeroes == nil then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	if mutil.IsRetreating(npcBot) and #tableNearbyEnemyHeroes >= 1
	then
		local location = npcBot:GetXUnitsTowardsLocation( GetAncient(GetTeam()):GetLocation(), nCastRange );
		return BOT_ACTION_DESIRE_MODERATE, location;
	end
	
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then		
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		then
			if mutil.IsDisabled(true, npcTarget) or npcTarget:GetMovementDirectionStability() < 1.0 then
				return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation( );
			else
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
			end
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderPrimalSpringEarly()

	if ( not abilityPSE:IsFullyCastable() or abilityPSE:IsHidden()  ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end

	
	local trees = npcBot:GetNearbyTrees(50);
	if trees == nil or #trees == 0 then
		return BOT_ACTION_DESIRE_NONE;
	end

	local nRadius = 375;
	
	if mutil.IsRetreating(npcBot)
	then
		return BOT_ACTION_DESIRE_MODERATE
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and 
		  ( GetUnitToLocationDistance(npcTarget, PSLoc) >= ( 375 - 125 ) or npcTarget:GetHealth() <= 175 )
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
	
end

function ConsiderMischief()
	
	if ( not abilityMC:IsFullyCastable() or abilityMC:IsHidden() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end
	

	if mutil.IsRetreating(npcBot) and ( npcBot:WasRecentlyDamagedByAnyHero(3.0) or npcBot:WasRecentlyDamagedByTower(3.0) )
	then
		local tableNearbyEnemy = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		if #tableNearbyEnemy >= 1 then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderUntransform()

	if ( not abilityUT:IsFullyCastable() or abilityUT:IsHidden() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end

	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and not mutil.IsInRange(npcTarget, npcBot, 1200)
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	if mutil.IsRetreating(npcBot) and not npcBot:WasRecentlyDamagedByAnyHero(4.0) 
	then
		return BOT_ACTION_DESIRE_MODERATE
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderWukongCommand()

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
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+(nRadius/2))
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
			if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(0.5);
			end
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end