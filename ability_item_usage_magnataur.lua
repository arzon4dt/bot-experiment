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

local castDCDesire = 0;
local castBLDesire = 0;
local castSCDesire = 0;
local castTWDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityDC = npcBot:GetAbilityByName( "magnataur_shockwave" );
	abilityBL = npcBot:GetAbilityByName( "magnataur_empower" );
	abilityTW = npcBot:GetAbilityByName( "magnataur_skewer" );
	abilitySC = npcBot:GetAbilityByName( "magnataur_reverse_polarity" );
	
	-- Consider using each ability
	castDCDesire, castDCLocation = ConsiderDecay();
	castBLDesire, castBLTarget = ConsiderBloodlust();
	castTWDesire, castTWLocation = ConsiderTimeWalk();
	castSCDesire = ConsiderSlithereenCrush();
	
	if ( castSCDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilitySC );
		return;
	end
	if ( castDCDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityDC, castDCLocation );
		return;
	end
	if ( castTWDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityTW, castTWLocation );
		return;
	end	
	if ( castBLDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityBL, castBLTarget );
		return;
	end
	
end

function CanCastDecayOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function CanCastBloodlustOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function CanCastSlithereenCrushOnTarget( npcTarget )
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
	local nRadius = abilityDC:GetSpecialValueInt( "radius" );
	local nCastRange = abilityDC:GetCastRange();
	local nCastPoint = abilityDC:GetCastPoint( );
	local nDamage = abilityDC:GetSpecialValueInt("shock_damage");

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastDecayOnTarget( npcTargetToKill ) )
	then
		if ( npcTargetToKill:IsHero() and  npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcTargetToKill:GetHealth() and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < ( nCastRange - 300 ) )
		then
			if npcTargetToKill:IsFacingUnit( npcBot, 45 ) then
				return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill:GetLocation();
			else
				return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill:GetXUnitsInFront(200);
			end
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
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 10000 );

		if ( locationAoE.count >= 2 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.6 ) 
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange - 200 and CanCastDecayOnTarget( npcTarget ) ) 
		then
				--[[if npcTarget:IsFacingUnit( npcBot, 45 ) then
					return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
				else
					return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetXUnitsInFront(200);
				end]]--
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation((GetUnitToUnitDistance(npcTarget, npcBot)/950)+nCastPoint);
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderBloodlust()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityBL:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityBL:GetCastRange();
	
	-- If we're pushing or defending a lane
	if ( npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
			if not npcBot:HasModifier("modifier_magnataur_empower") then
				return BOT_ACTION_DESIRE_MODERATE, npcBot;
			end
			local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
			for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
				if ( GetUnitToUnitDistance( myFriend, npcBot  ) < nCastRange and not myFriend:HasModifier("modifier_magnataur_empower") ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, myFriend;
				end
			end	
	end
	
	-- If we're pushing or defending a lane
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT  ) 
	then
			if not npcBot:HasModifier("modifier_magnataur_empower") then
				return BOT_ACTION_DESIRE_MODERATE, npcBot;
			end
			local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
			for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
				if ( GetUnitToUnitDistance( myFriend, npcBot  ) < nCastRange and not myFriend:HasModifier("modifier_magnataur_empower") ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, myFriend;
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
			if not npcBot:HasModifier("modifier_magnataur_empower") then
				return BOT_ACTION_DESIRE_MODERATE, npcBot;
			end
			local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
			for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
				if ( GetUnitToUnitDistance( myFriend, npcBot  ) < nCastRange and not myFriend:HasModifier("modifier_magnataur_empower") ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, myFriend;
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
	if ( not abilityTW:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	
	-- Get some of its values
	local nCastRange = abilityTW:GetSpecialValueInt("range");
	local nCastPoint = abilityTW:GetCastPoint( );

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 600, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				local location = npcBot:GetXUnitsInFront( nCastRange );
				if GetOpposingTeam( ) == TEAM_DIRE then
					location = RB;
				end
				if GetOpposingTeam( ) == TEAM_RADIANT then
					location = DB;
				end
				return BOT_ACTION_DESIRE_MODERATE, location;
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
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange - 400 ) 
		then
			--[[if npcTarget:IsFacingUnit( npcBot, 45 ) then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
			else
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetXUnitsInFront(300);
			end]]--
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation((GetUnitToUnitDistance(npcTarget, npcBot)/950)+nCastPoint);
		end
	end
	
--
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderSlithereenCrush()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilitySC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRadius = abilitySC:GetSpecialValueInt( "pull_radius" );
	local nCastRange = 0;
	local nDamage = abilitySC:GetSpecialValueInt("polarity_damage");

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + nRadius, true, BOT_MODE_NONE );
		local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 800, false, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCastSlithereenCrushOnTarget( npcEnemy ) and #tableNearbyAllyHeroes >= 2 ) 
				then
					return BOT_ACTION_DESIRE_MODERATE;
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
		if ( npcTarget ~= nil and npcTarget:IsHero() ) 
		then
			local EnemyHeroes = npcBot:GetNearbyHeroes( nRadius - 150, true, BOT_MODE_NONE );
			if ( CanCastSlithereenCrushOnTarget( npcTarget ) and #EnemyHeroes >= 2 )
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

