--require(GetScriptDirectory() ..  "/ability_item_usage_generic")
ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local inspect = require(GetScriptDirectory() ..  "/inspect")
local enemyStatus = require(GetScriptDirectory() .. "/enemy_status" )

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end

castTODesire = 0;
castCSDesire = 0;
castACDesire = 0;
castGWDesire = 0;
castEMPDesire = 0;
castCMDesire = 0;
castDBDesire = 0;
castIWDesire = 0;
castSSDesire = 0;
castFSDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end;
	--if ( npcBot:HasModifier('invoker_ghost_walk') ) then return end;

	abilityQ = npcBot:GetAbilityByName( "invoker_quas" );
	abilityW = npcBot:GetAbilityByName( "invoker_wex" );
	abilityE = npcBot:GetAbilityByName( "invoker_exort" );
	abilityR = npcBot:GetAbilityByName( "invoker_invoke" );
	abilityTO = npcBot:GetAbilityByName( "invoker_tornado" );
	abilityCS = npcBot:GetAbilityByName( "invoker_cold_snap" );
	abilityAC = npcBot:GetAbilityByName( "invoker_alacrity" );
	abilityGW = npcBot:GetAbilityByName( "invoker_ghost_walk" );
	abilityEMP = npcBot:GetAbilityByName( "invoker_emp" );
	abilityCM = npcBot:GetAbilityByName( "invoker_chaos_meteor" );
	abilityDB = npcBot:GetAbilityByName( "invoker_deafening_blast" );
	abilityIW = npcBot:GetAbilityByName( "invoker_ice_wall" );
	abilitySS = npcBot:GetAbilityByName( "invoker_sun_strike" );
	abilityFS = npcBot:GetAbilityByName( "invoker_forge_spirit" );
	
	
	-- Consider using each ability
	ConsiderDamage();
	
	ConsiderShowUp(npcBot);
	
	castTODesire, castTOLocation = ConsiderTornado();
	castEMPDesire, castEMPLocation = ConsiderEMP();
	castCMDesire, castCMLocation = ConsiderChaosMeteor();
	castDBDesire, castDBLocation = ConsiderDeafeningBlast();
	castSSDesire, castSSLocation = ConsiderSunStrike();
	castCSDesire, castCSTarget = ConsiderColdSnap();
	castACDesire = ConsiderAlacrity();
	castGWDesire = ConsiderGhostWalk();
	castIWDesire = ConsiderIceWall();
	castFSDesire = ConsiderForgedSpirit();
	
	if ( castTODesire > 0 and not inGhostWalk(npcBot)  ) 
	then
		print("cast TO")
		if(invokeTornado() or not abilityTO:IsHidden()) then
			npcBot:Action_UseAbilityOnLocation( abilityTO, castTOLocation );
		end
		return;
	end
	
	if ( castEMPDesire > 0 and not inGhostWalk(npcBot) ) 
	then
		print("cast EMP")
		if(invokeEMP() or not abilityEMP:IsHidden()) then
			npcBot:Action_UseAbilityOnLocation( abilityEMP, castEMPLocation );
		end
		return;
	end
	
	if ( castCMDesire > 0 and not inGhostWalk(npcBot) ) 
	then
		print("cast CM")
		if(invokeChaosMeteor() or not abilityCM:IsHidden()) then
			npcBot:Action_UseAbilityOnLocation( abilityCM, castCMLocation );
		end
		return;
	end
	
	if ( castDBDesire > 0 and not inGhostWalk(npcBot) ) 
	then
		print("cast DB")
		if(invokeDeafeningBlast() or not abilityDB:IsHidden()) then
			npcBot:Action_UseAbilityOnLocation( abilityDB, castDBLocation );
		end
		return;
	end
		
	if ( castCSDesire > 0 and not inGhostWalk(npcBot) ) 
	then
		print("cast CS")
		if(invokeColdSnap() or not abilityCS:IsHidden()) then
			npcBot:Action_UseAbilityOnEntity( abilityCS, castCSTarget );
		end
		return;
	end
	
	if ( castSSDesire > 0 and not inGhostWalk(npcBot) ) 
	then
		print("cast SS")
		if(invokeSunStrike() or not abilitySS:IsHidden()) then
			npcBot:Action_UseAbilityOnLocation( abilitySS, castSSLocation );
		end
		return;
	end
	
	if ( castACDesire > 0 and not inGhostWalk(npcBot) ) 
	then
		print("cast AC")
		if(invokeAlacrity() or not abilityAC:IsHidden()) then
			npcBot:Action_UseAbilityOnEntity( abilityAC, npcBot );
		end
		return;
	end
	
	if ( castFSDesire > 0 and not inGhostWalk(npcBot) ) 
	then
		print("cast FS")
		if(invokeForgedSpirit() or not abilityFS:IsHidden()) then
			npcBot:Action_UseAbility( abilityFS );
		end
		return;
	end
	
	if ( castIWDesire > 0 and not inGhostWalk(npcBot) ) 
	then
		print("cast IW")
		if(invokeIceWall() or not abilityIW:IsHidden()) then
			npcBot:Action_UseAbility( abilityIW );
		end
		return;
	end

	if ( castGWDesire > 0 and not inGhostWalk(npcBot) ) 
	then
		print("cast GW")
		if(invokeGhostWalk() or not abilityGW:IsHidden()) then
			npcBot:Action_UseAbility( abilityGW );
		end
		return;
	end

end

function inGhostWalk(npcInvo)
	if (npcInvo:HasModifier("modifier_invoker_ghost_walk")) then
		return true;
	end
	return false;
end

function ConsiderShowUp(npcInvo)
	
	if ( npcInvo:HasModifier("modifier_invoker_ghost_walk") ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
		if(#tableNearbyEnemyHeroes <= 1 or npcInvo:HasModifier("modifier_item_dust") ) then
			npcInvo:Action_UseAbility( abilityW );
			npcInvo:Action_UseAbility( abilityW );
		end
	end
end

function quasTrained()
	if(abilityQ:IsTrained( )) then
		return true;
	end
	return false;
end

function wexTrained()
	if(abilityW:IsTrained( )) then
		return true;
	end
	return false;
end

function exortTrained()
	if(abilityE:IsTrained( )) then
		return true;
	end
	return false;
end

function invokeTornado()
	local npcBot = GetBot();
	local count = 0;
	
	-- Make sure invoke is castable
	if ( not abilityR:IsFullyCastable() ) then 
		return false;
	end
	
	if ( not abilityTO:IsHidden() ) 
	then 
		print("To Available")
		return false;
	else
		print("TO Hidden")
	end;
	print("Inv TO")
	npcBot:Action_UseAbility( abilityW ); count = count + 1;
	npcBot:Action_UseAbility( abilityQ ); count = count + 1;
	npcBot:Action_UseAbility( abilityW ); count = count + 1;
	if(count == 3) then
		count = 0;
		npcBot:Action_UseAbility( abilityR );
	end
	return true;
end

function invokeChaosMeteor()
	local npcBot = GetBot();
	local count = 0;
	
	-- Make sure invoke is castable
	if ( not abilityR:IsFullyCastable() ) then 
		return false;
	end
	
	if ( not abilityCM:IsFullyCastable() ) 
	then 
		return false;
	end;
	
	if ( not abilityCM:IsHidden() ) 
	then 
		return false;
	end;
	
	npcBot:Action_UseAbility( abilityE ); count = count + 1;
	npcBot:Action_UseAbility( abilityE ); count = count + 1;
	npcBot:Action_UseAbility( abilityW ); count = count + 1;
	if(count == 3) then
		count = 0;
		npcBot:Action_UseAbility( abilityR );
	end
	return true;
end

function invokeDeafeningBlast()
	local npcBot = GetBot();
	local count = 0;
	
	-- Make sure invoke is castable
	if ( not abilityR:IsFullyCastable() ) then 
		return false;
	end
	
	if ( not abilityDB:IsFullyCastable() ) 
	then 
		return false;
	end;
	
	if ( not abilityDB:IsHidden() ) 
	then 
		return false;
	end;
	
	npcBot:Action_UseAbility( abilityQ ); count = count + 1;
	npcBot:Action_UseAbility( abilityW ); count = count + 1;
	npcBot:Action_UseAbility( abilityE ); count = count + 1;
	if(count == 3) then
		count = 0;
		npcBot:Action_UseAbility( abilityR );
	end
	return true;
end

function invokeForgedSpirit()
	local npcBot = GetBot();
	local count = 0;
	
	-- Make sure invoke is castable
	if ( not abilityR:IsFullyCastable() ) then 
		return false;
	end
	
	if ( not abilityFS:IsFullyCastable() ) 
	then 
		return false;
	end;
	
	if ( not abilityFS:IsHidden() ) 
	then 
		return false;
	end;
	
	npcBot:Action_UseAbility( abilityE ); count = count + 1;
	npcBot:Action_UseAbility( abilityQ ); count = count + 1;
	npcBot:Action_UseAbility( abilityE ); count = count + 1;
	if(count == 3) then
		count = 0;
		npcBot:Action_UseAbility( abilityR );
	end
	return true;
end

function invokeIceWall()
	local npcBot = GetBot();
	local count = 0;
	
	-- Make sure invoke is castable
	if ( not abilityR:IsFullyCastable() ) then 
		return false;
	end
	
	if ( not abilityIW:IsFullyCastable() ) 
	then 
		return false;
	end;
	
	if ( not abilityIW:IsHidden() ) 
	then 
		return false;
	end;
	
	npcBot:Action_UseAbility( abilityQ ); count = count + 1;
	npcBot:Action_UseAbility( abilityQ ); count = count + 1;
	npcBot:Action_UseAbility( abilityE ); count = count + 1;
	if(count == 3) then
		count = 0;
		npcBot:Action_UseAbility( abilityR );
	end
	return true;
end

function invokeEMP()
	local npcBot = GetBot();
	local count = 0;
	
	-- Make sure invoke is castable
	if ( not abilityR:IsFullyCastable() ) then 
		return false;
	end
	
	if ( not abilityEMP:IsFullyCastable() ) 
	then 
		return false;
	end;
	
	if ( not abilityEMP:IsHidden() ) 
	then 
	    
		return false;
	end;
	
	npcBot:Action_UseAbility( abilityW ); count = count + 1;
	npcBot:Action_UseAbility( abilityW ); count = count + 1;
	npcBot:Action_UseAbility( abilityW ); count = count + 1;
	if(count == 3) then
		count = 0;
		npcBot:Action_UseAbility( abilityR );
	end
	return true;
end


function invokeColdSnap()
	local npcBot = GetBot();
	local count = 0;
	
	-- Make sure invoke is castable
	if ( not abilityR:IsFullyCastable() ) then 
		return false;	
	end
	
	if ( not abilityCS:IsFullyCastable() ) 
	then 
		return false;
	end;
	
	if ( not abilityCS:IsHidden() ) 
	then 
		return false;
	end;
	
	npcBot:Action_UseAbility( abilityQ ); count = count + 1;
	npcBot:Action_UseAbility( abilityQ ); count = count + 1;
	npcBot:Action_UseAbility( abilityQ ); count = count + 1;
	if(count == 3) then
		count = 0;
		npcBot:Action_UseAbility( abilityR );
	end
	return true;
end

function invokeSunStrike()
	local npcBot = GetBot();
	local count = 0;
	
	-- Make sure invoke is castable
	if ( not abilityR:IsFullyCastable() ) then 
		return false;	
	end
	
	if ( not abilitySS:IsFullyCastable() ) 
	then 
		return false;
	end;
	
	if ( not abilitySS:IsHidden() ) 
	then 
		return false;
	end;
	
	npcBot:Action_UseAbility( abilityE ); count = count + 1;
	npcBot:Action_UseAbility( abilityE ); count = count + 1;
	npcBot:Action_UseAbility( abilityE ); count = count + 1;
	if(count == 3) then
		count = 0;
		npcBot:Action_UseAbility( abilityR );
	end
	return true;
end

function invokeAlacrity()
	local npcBot = GetBot();
	local count = 0;
	
	-- Make sure invoke is castable
	if ( not abilityR:IsFullyCastable() ) then 
		return false;
	end
	
	if ( not abilityAC:IsFullyCastable() ) 
	then 
		return false;
	end;
	
	if ( not abilityAC:IsHidden() ) 
	then 
		return false;
	end;
	
	npcBot:Action_UseAbility( abilityW ); count = count + 1;
	npcBot:Action_UseAbility( abilityE ); count = count + 1;
	npcBot:Action_UseAbility( abilityW ); count = count + 1;
	if(count == 3) then
	    count = 0;
		npcBot:Action_UseAbility( abilityR );
	end
	return true;
end

function invokeGhostWalk()
	local npcBot = GetBot();
	local count = 0;
	
	-- Make sure invoke is castable
	if ( not abilityR:IsFullyCastable() ) then 
		return false;
	end
	
	if ( not abilityGW:IsFullyCastable() ) 
	then 
		return false;
	end;
	
	if ( not abilityGW:IsHidden() ) 
	then 
		return false;
	end;
	
	npcBot:Action_UseAbility( abilityQ ); count = count + 1;
	npcBot:Action_UseAbility( abilityW ); count = count + 1;
	npcBot:Action_UseAbility( abilityQ ); count = count + 1;
	if(count == 3) then
	    count = 0;
		npcBot:Action_UseAbility( abilityR );
	end
	return true;
end


function tripleExortBuff()
	local npcBot = GetBot();
	npcBot:Action_UseAbility( abilityE );
	npcBot:Action_UseAbility( abilityE );
	npcBot:Action_UseAbility( abilityE );
end

function ConsiderDamage()
	local npcBot = GetBot();
	if(DotaTime( ) >= -1.0 and DotaTime( ) <= 0.1)then
		npcBot:Action_UseAbility( abilityE );
		npcBot:Action_UseAbility( abilityE );
		npcBot:Action_UseAbility( abilityE );
	end
end

function CanCastColdSnapOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function CanCastDeafeningBlastOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function ConsiderTornado()

	local npcBot = GetBot();

	if ( not quasTrained() or not wexTrained() ) then	
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Make sure it's castable
	if ( not abilityTO:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end;

	-- Get some of its values
	local nDistance = abilityTO:GetSpecialValueInt( "travel_distance" );
	local nCastRange = abilityTO:GetCastRange();
	local nBDamage = abilityTO:GetSpecialValueInt( "base_damage" );
	local nWDamage = abilityTO:GetSpecialValueInt( "wex_damage" );

	--------------------------------------
	-- Global high-priorty usage
	--------------------------------------

	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nDistance, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
		end
	end

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nDistance, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end

	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 1 ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nDistance - 200, 200, 0, 0 );

		if ( locationAoE.count >= 1 ) 
		then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nDistance - 200 ) 
		then
			--return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( GetUnitToUnitDistance(npcTarget, npcBot) / 1000 );
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderIceWall()

	local npcBot = GetBot();

	if ( not quasTrained() or not exortTrained() ) then	
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- Make sure it's castable
	if ( not abilityIW:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end;

	-- Get some of its values
	local nCastRange = abilityIW:GetSpecialValueInt( "wall_place_distance" );
	local nRadius = abilityIW:GetSpecialValueInt( "wall_element_radius" );

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) or GetUnitToUnitDistance(npcEnemy, npcBot) < (nCastRange + nRadius) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end

	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 1 ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, 2*nRadius, 0, 0 );
		if ( locationAoE.count >= 1 ) 
		then
			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 2*nCastRange, true, BOT_MODE_NONE );
				for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
				do
					if ( GetUnitToUnitDistance( npcEnemy, npcBot ) < (nCastRange + nRadius) ) 
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

		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, npcBot ) < (nCastRange + nRadius) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderChaosMeteor()

	local npcBot = GetBot();

	if ( not exortTrained() or not wexTrained() ) then	
		return  BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Make sure it's castable
	if ( not abilityCM:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end;

	-- Get some of its values
	local nCastRange = abilityCM:GetCastRange();
	local nRadius = abilityCM:GetSpecialValueInt("area_of_effect");

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );

		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
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
			if ( npcTarget:IsRooted() or npcTarget:IsStunned() or npcTarget:IsHexed( ) or npcTarget:IsNightmared( )  ) 
			then
				--return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( 1.3 );
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderSunStrike()

	local npcBot = GetBot();

	if ( not exortTrained() ) then	
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Make sure it's castable
	if ( not abilitySS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end;

	-- Get some of its values
	local nRadius = abilitySS:GetSpecialValueInt("area_of_effect");

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcEnemy:IsRooted() or npcEnemy:IsStunned() or npcEnemy:IsHexed() or npcEnemy:IsNightmared( )  ) 
			then
				--return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation( 1.7 );
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

		if ( npcTarget ~= nil ) 
		then
			if ( npcTarget:IsRooted() or npcTarget:IsStunned() or npcTarget:IsHexed( ) or npcTarget:IsNightmared( )  ) 
			then
				--return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( 1.7 );
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderDeafeningBlast()

	local npcBot = GetBot();

	if ( not quasTrained() or  not wexTrained() or not exortTrained() ) then	
		return  BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Make sure it's castable
	if ( not abilityDB:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end;

	-- Get some of its values
	local nCastRange = abilityDB:GetCastRange();
	local nRadius = abilityDB:GetSpecialValueInt("radius_end");
	local nDamage = abilityDB:GetSpecialValueInt("damage");

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 1 ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		if ( locationAoE.count >= 2 and #tableNearbyEnemyHeroes > 0 ) 
		then
			for _,npcEnemy in pairs (tableNearbyEnemyHeroes)
			do
				if CanCastDeafeningBlastOnTarget (npcEnemy) then
					return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
				end
			end
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and CanCastDeafeningBlastOnTarget (npcEnemy) )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = npcBot:GetTarget();
	if ( npcTarget ~= nil and npcTarget:IsHero() )
	then
		if( npcTarget:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL  ) > npcTarget:GetHealth() and 
			GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange - (nCastRange/3) and 
			CanCastDeafeningBlastOnTarget (npcTarget) )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and 
			GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange - (nCastRange/3) and 
			CanCastDeafeningBlastOnTarget (npcTarget) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderEMP()

	local npcBot = GetBot();

	if ( not wexTrained() ) then	
		return  BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Make sure it's castable
	if ( not abilityEMP:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end;

	-- Get some of its values
	local nCastRange = abilityEMP:GetCastRange();
	local nRadius = abilityEMP:GetSpecialValueInt( "area_of_effect" );
	local nBurn = abilityEMP:GetSpecialValueInt( "mana_burned" );
	local nPDamage = abilityEMP:GetSpecialValueInt( "damage_per_mana_pct" );

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 1 ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, ( nRadius/2 ), 0, 0 );

		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
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

		if ( npcTarget ~= nil and npcTarget:HasModifier("modifier_invoker_tornado") and GetUnitToUnitDistance( npcTarget, npcBot ) < (nCastRange - (nRadius / 2)) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation( );
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderGhostWalk()

	local npcBot = GetBot();

	if ( not quasTrained() or not wexTrained() ) then	
		return  BOT_ACTION_DESIRE_NONE;
	end
	
	-- Make sure it's castable
	if ( not abilityGW:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end;

	--------------------------------------
	-- Global high-priorty usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 600, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) or GetUnitToUnitDistance( npcEnemy, npcBot ) < 600 )
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderColdSnap()

	local npcBot = GetBot();

	if ( not quasTrained() ) then	
		return  BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Make sure it's castable
	if ( not abilityCS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end;

	-- Get some of its values
	local nCastRange = abilityCS:GetCastRange();

	--------------------------------------
	-- Global high-priorty usage
	--------------------------------------

	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and CanCastColdSnapOnTarget(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end

	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 1 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( GetUnitToUnitDistance( npcEnemy, npcBot ) < ( nCastRange ) and CanCastColdSnapOnTarget(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
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

		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange and CanCastColdSnapOnTarget(npcTarget) ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderAlacrity()

	local npcBot = GetBot();

	if ( not wexTrained() or not exortTrained() ) then	
		return  BOT_ACTION_DESIRE_NONE;
	end
	
	-- Make sure it's castable
	if ( not abilityAC:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end;

	
	--------------------------------------
	-- Global high-priorty usage
	--------------------------------------
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOTTOM or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOTTOM ) 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( 600, true );
		local tableNearbyEnemyTowers = npcBot:GetNearbyTowers( 600, true );
		if ( #tableNearbyEnemyCreeps >= 3 or #tableNearbyEnemyTowers > 0 ) 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	--------------------------------------
	-- Mode based usage
	--------------------------------------


	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 600, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( GetUnitToUnitDistance( npcEnemy, npcBot ) < 600 ) 
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < 600 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
			local npcTarget = npcBot:GetTarget();
			if ( npcTarget ~= nil  )
			then
				return BOT_ACTION_DESIRE_LOW;
			end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderForgedSpirit()

	local npcBot = GetBot();

	if ( not quasTrained() or not exortTrained() ) then	
		return  BOT_ACTION_DESIRE_NONE;
	end
	
	-- Make sure it's castable
	if ( not abilityFS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end;

	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
			local npcTarget = npcBot:GetTarget();
			if ( npcTarget ~= nil  )
			then
				return BOT_ACTION_DESIRE_LOW;
			end
	end
	
	--------------------------------------
	-- Global high-priorty usage
	--------------------------------------
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOTTOM or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOTTOM ) 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( 600, true );
		local tableNearbyEnemyTowers = npcBot:GetNearbyTowers( 600, true );
		if ( #tableNearbyEnemyCreeps >= 3 or #tableNearbyEnemyTowers > 0 ) 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	--------------------------------------
	-- Mode based usage
	--------------------------------------


	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 600, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( GetUnitToUnitDistance( npcEnemy, npcBot ) < 600 ) 
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
		if ( npcTarget ~= nil and npcTarget:IsHero()  and GetUnitToUnitDistance( npcTarget, npcBot ) < 600 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	
	return BOT_ACTION_DESIRE_NONE;
end