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

local castTWDesire = 0;
local castFBDesire = 0;
local castTDDesire = 0;
function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsCastingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end
	
	abilityTD = npcBot:GetAbilityByName( "storm_spirit_static_remnant" );
	abilityFB = npcBot:GetAbilityByName( "storm_spirit_electric_vortex" );
	abilityTW = npcBot:GetAbilityByName( "storm_spirit_ball_lightning" );
	
	castTDDesire = ConsiderTimeDilation();
	castFBDesire, castFBTarget = ConsiderFireblast();
	castTWDesire, castTWLocation = ConsiderTimeWalk();
	
	if ( castTWDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityTW, castTWLocation );
		return;
	end
	if ( castFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		return;
	end
	if ( castTDDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityTD );
		return;
	end


end

function CanCastFireblastOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function GetTowardsFountainLocation( unitLoc, distance )
	local destination = {};
	if ( GetTeam() == TEAM_RADIANT ) then
		destination[1] = unitLoc[1] - distance / math.sqrt(2);
		destination[2] = unitLoc[2] - distance / math.sqrt(2);
	end

	if ( GetTeam() == TEAM_DIRE ) then
		destination[1] = unitLoc[1] + distance / math.sqrt(2);
		destination[2] = unitLoc[2] + distance / math.sqrt(2);
	end
	return Vector(destination[1], destination[2]);
end

function BallLightningAllowed(manaCost)
	local npcBot = GetBot();
	if ( npcBot:GetMana() - manaCost ) / npcBot:GetMaxMana() >= 0.20
	then
		return true
	end
	return false
end

function ConsiderFireblast()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityFB:GetCastRange();

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 3*nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 2*nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCastFireblastOnTarget( npcEnemy ) ) 
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy;
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
			if ( CanCastFireblastOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange + 200 )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderTimeWalk()

	local RB = Vector(-7200,-6666)
	local DB = Vector(7137,6548)
	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilityTW:IsFullyCastable() or abilityTW:IsInAbilityPhase() or npcBot:HasModifier("modifier_storm_spirit_ball_lightning") ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastPoint = abilityTW:GetCastPoint( );
	local nInitialMana = abilityTW:GetSpecialValueInt("ball_lightning_initial_mana_base")
	local nInitialManaP = abilityTW:GetSpecialValueInt("ball_lightning_initial_mana_percentage") / 100
	local nTravelCost = abilityTW:GetSpecialValueInt("ball_lightning_travel_cost_base")
	local nTravelCostP = abilityTW:GetSpecialValueFloat("ball_lightning_travel_cost_percent") / 100

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( npcBot:WasRecentlyDamagedByAnyHero(2.0) or npcBot:WasRecentlyDamagedByTower(2.0) or ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 1  ) )
		then
			--return BOT_ACTION_DESIRE_MODERATE, GetTowardsFountainLocation(npcBot:GetLocation(), 600);
			local location = npcBot:GetXUnitsTowardsLocation( GetAncient(GetTeam()):GetLocation(), 600 );
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
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) > 500 and GetUnitToUnitDistance( npcTarget, npcBot ) < 1000 ) 
		then
			local MaxMana = npcBot:GetMaxMana();
			local distance = GetUnitToUnitDistance( npcTarget, npcBot );
			local tableNearbyAllyHeroes = npcTarget:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
			local TotalInitMana = nInitialMana + ( nInitialManaP * MaxMana );
			local TotalTravelMana = ( nTravelCost * ( distance / 100 ) ) + ( nTravelCostP * MaxMana * ( distance / 100 ) );
			local TotalMana = TotalInitMana + TotalTravelMana;
			--print(TotalMana)
			if tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes >= 2 and BallLightningAllowed( TotalMana ) then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( 2*nCastPoint );
			end
		end
	end
	
	--[[local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsUsingAbility() ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcBot:GetLocation() + RandomVector(50);
		end
	end]]--
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderTimeDilation()

	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilityTD:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- Get some of its values
	local nRadius = abilityTD:GetSpecialValueInt("static_remnant_radius");

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if (tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1) then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( nRadius, true );
		if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 4 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.65 then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil  and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nRadius ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
--
	return BOT_ACTION_DESIRE_NONE;
end

