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

local castASDesire = 0;
local castSCDesire = 0;
local castSPDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilitySC = npcBot:GetAbilityByName( "elder_titan_echo_stomp" );
	abilityAS = npcBot:GetAbilityByName( "elder_titan_ancestral_spirit" );
	abilitySP = npcBot:GetAbilityByName( "elder_titan_earth_splitter" );

	-- Consider using each ability
	castSCDesire = ConsiderSlithereenCrush();
	castASDesire, castASLocation = ConsiderAncestralSpirit();
	castSPDesire, castSPLocation = ConsiderShadowPoison();
	
	if ( castSPDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilitySP, castSPLocation );
		return;
	end
	
	if ( castASDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityAS, castASLocation );
		return;
	end
	
	if ( castSCDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilitySC );
		return;
	end
	
end

function CanCastSlithereenCrushOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function CanCastAncestralSpiritOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function CanCastShadowPoisonOnTarget( npcTarget )
	return not npcTarget:IsInvulnerable();
end


function ConsiderSlithereenCrush()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilitySC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRadius = abilitySC:GetSpecialValueInt( "radius" );
	local nCastRange = 0;
	local nDamage = abilitySC:GetSpecialValueInt( "stomp_damage" );

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_LOW;
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
				if ( CanCastSlithereenCrushOnTarget( npcEnemy ) ) 
				then
					return BOT_ACTION_DESIRE_MODERATE;
				end
			end
		end
	end

	if ( npcBot:GetActiveMode() == BOT_MODE_FARM or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), 0, nRadius, 0, 1500 );
		if ( locationAoE.count >= 3 and GetUnitToLocationDistance( npcBot, locationAoE.targetloc ) < nRadius - 200 and npcBot:GetMana()/npcBot:GetMaxMana() > 0.6 ) then
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

		if ( npcTarget ~= nil ) 
		then
			if ( CanCastSlithereenCrushOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nRadius - 200 )
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderAncestralSpirit()

	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilityAS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nRadius = abilityAS:GetSpecialValueInt( "radius" );
	local nCastRange = abilityAS:GetCastRange();
	local nCastPoint = abilityAS:GetCastPoint( );
	local nDamage = abilityAS:GetSpecialValueInt("pass_damage");

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastAncestralSpiritOnTarget( npcTargetToKill ) )
	then
		if ( npcTargetToKill:IsHero() and  npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcTargetToKill:GetHealth() and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < nCastRange - 200 )
		then
			--[[if npcTargetToKill:IsFacingUnit( npcBot, 45 ) then
				return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill:GetLocation();
			else
				return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill:GetXUnitsInFront(200);
			end]]--
			return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill:GetExtrapolatedLocation( 2*nCastPoint );
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
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 10000 );
		if ( locationAoE.count >= 2 and GetUnitToLocationDistance( npcBot, locationAoE.targetloc ) < nCastRange - 200 ) then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
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
		local locationHAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 1000 );
		if ( locationHAoE.count >= 2 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.6 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationHAoE.targetloc;
		end
		local locationCAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 1000 );
		if ( locationCAoE.count >= 3 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.6 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationCAoE.targetloc;
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange - 200 and CanCastAncestralSpiritOnTarget( npcTarget )  ) 
		then
			--return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
			return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill:GetExtrapolatedLocation( 2*nCastPoint );
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderShadowPoison()

	local npcBot = GetBot();
	
	-- Make sure it's castable
	if ( not abilitySP:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilitySP:GetSpecialValueInt("crack_width");
	local nCastRange = abilitySP:GetCastRange();
	local nCastPoint = abilitySP:GetCastPoint();
	local nPercentageHP = abilitySP:GetSpecialValueInt("damage_pct");
	local nCrackTime = abilitySP:GetSpecialValueInt("crack_time");

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastShadowPoisonOnTarget( npcTargetToKill ) )
	then
		if ( npcTargetToKill:IsHero() and  npcTargetToKill:GetActualIncomingDamage( ( nPercentageHP / 100 ) * npcTargetToKill:GetMaxHealth(), DAMAGE_TYPE_MAGICAL ) > npcTargetToKill:GetHealth() - 200 and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < nCastRange - 400 )
		then
			--return BOT_ACTION_DESIRE_LOW, npcTargetToKill:GetLocation();
			return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill:GetExtrapolatedLocation( nCastPoint + nCrackTime - 1 );
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 750, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				--return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation( nCastPoint + nCrackTime - 1.5 );
			end
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), 1000, nRadius, 0, 10000 );
		if ( locationAoE.count >= 2 and GetUnitToLocationDistance( npcBot, locationAoE.targetloc ) < nCastRange - 400 ) then
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
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange - 400 and ( #tableNearbyEnemyHeroes - 1 ) >= 2  ) 
		then
			if ( CanCastShadowPoisonOnTarget( npcTarget ) )
			then
				--return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint + nCrackTime - 1.5 );
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end
