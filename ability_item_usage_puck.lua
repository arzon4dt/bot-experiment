if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end


--require(GetScriptDirectory() ..  "/ability_item_usage_generic")
local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local inspect = require(GetScriptDirectory() ..  "/inspect")
local enemyStatus = require(GetScriptDirectory() .. "/enemy_status" )
local mutil = require(GetScriptDirectory() ..  "/MyUtility")

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end

local castPhaseDesire = 0;
local castJauntDesire = 0;
local castCoilDesire = 0;
local castSilenceDesire = 0;
local castOrbDesire = 0;
local castBlinkInitDesire = 0; 
local castForceEnemyDesire = 0;

----------------------------------------------------------------------------------------------------
local courierTime = 0
local illuOrbLoc = nil;

function CourierUsageThink()
	local npcBot = GetBot()

	if (IsCourierAvailable() and
		npcBot:DistanceFromFountain() < 9000 and 
		DotaTime() > (courierTime + 5) and
		(npcBot:GetCourierValue( ) > 0 or
		npcBot:GetStashValue( ) > 0) and
		npcBot:GetActiveMode() ~= BOT_MODE_ATTACK and
		npcBot:GetActiveMode() ~= BOT_MODE_RETREAT and
		npcBot:GetActiveMode() ~= BOT_MODE_EVASIVE_MANEUVERS and
		npcBot:GetActiveMode() ~= BOT_MODE_DEFEND_ALLY)
	then
		npcBot:ActionImmediate_Courier( npcBot, COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS )
		courierTime = DotaTime()
	end
end
----------------------------------------------------------------------------------------------------

function AbilityUsageThink()
local npcBot = GetBot();
local sideOfMap = 0
	--print(utils.GetLocationDanger(npcBot:GetLocation()))
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end
	
	
	abilityOrb = npcBot:GetAbilityByName( "puck_illusory_orb" );
	abilitySilence = npcBot:GetAbilityByName( "puck_waning_rift" );
	abilityPhase = npcBot:GetAbilityByName( "puck_phase_shift" );
	abilityJaunt = npcBot:GetAbilityByName( "puck_ethereal_jaunt" );
	abilityCoil = npcBot:GetAbilityByName( "puck_dream_coil" );
	itemForce = "item_force_staff";
	itemBlink = "item_blink";
	for i=0, 5 do
		if(npcBot:GetItemInSlot(i) ~= nil) then
			local _item = npcBot:GetItemInSlot(i):GetName()
			if(_item == itemBlink) then
				itemBlink = npcBot:GetItemInSlot(i);
			end
			if(_item == itemForce) then
				itemForce = npcBot:GetItemInSlot(i);
			end
		end
	end
 

	-- Consider using each ability

	castPhaseDesire = ConsiderPhaseShift();
	castSilenceDesire = ConsiderWaningRift();
	castCoilDesire, castCoilTarget = ConsiderDreamCoil();
	castJauntDesire = ConsiderEtherealJaunt();
	castBlinkInitDesire, castBlinkInitTarget = ConsiderBlinkInit();
	castForceEnemyDesire, castForceEnemyTarget = ConsiderForceEnemy();
	castOrbDesire, castOrbTarget = ConsiderIllusoryOrb();

	local highestDesire = castOrbDesire;
	local desiredSkill = 1;

	if ( castSilenceDesire > highestDesire) 
		then
			highestDesire = castSilenceDesire;
			desiredSkill = 2;
	end

	if ( castPhaseDesire > highestDesire) 
		then
			highestDesire = castPhaseDesire;
			desiredSkill = 3;
	end

	if ( castJauntDesire > highestDesire) 
		then
			highestDesire = castJauntDesire;
			desiredSkill = 4;
	end

	if ( castCoilDesire > highestDesire) 
		then
			highestDesire = castCoilDesire;
			desiredSkill = 5;
	end

	if ( castBlinkInitDesire > highestDesire) 
		then
			highestDesire = castBlinkInitDesire;
			desiredSkill = 6;
	end

	if ( castForceEnemyDesire > highestDesire) 
		then
			highestDesire = castForceEnemyDesire;
			desiredSkill = 7;
	end

	--print("desires".. castOrbDesire .. castSilenceDesire .. castPhaseDesire .. castJauntDesire .. castCoilDesire);
	if highestDesire == 0 then return;
    elseif desiredSkill == 1 then 
		illuOrbLoc = castOrbTarget;
		npcBot:Action_UseAbilityOnLocation( abilityOrb, castOrbTarget );
    elseif desiredSkill == 2 then 
		npcBot:Action_UseAbility( abilitySilence);
    elseif desiredSkill == 3 then 
		npcBot:Action_UseAbility( abilityPhase);
    elseif desiredSkill == 4 then 
		npcBot:Action_UseAbility( abilityJaunt );
    elseif desiredSkill == 5 then 
		npcBot:Action_UseAbilityOnLocation( abilityCoil, castCoilTarget );
    elseif desiredSkill == 6 then 
		performBlinkInit( castBlinkInitTarget );
    elseif desiredSkill == 7 then 
		performForceEnemy( castForceEnemyTarget );
	end	

end

----------------------------------------------------------------------------------------------------

function CanCastIllusoryOrbOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end


function CanCastWaningRiftOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end


function CanCastDreamCoilOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and npcTarget:IsHero() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

----------------------------------------------------------------------------------------------------

function ConsiderIllusoryOrb()

	local npcBot = GetBot();
	
	-- Make sure it's castable
	if ( not abilityOrb:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- If we want to cast Phase Shift at all, bail
	if ( castPhaseDesire > 0 or castCoilDesire > 50 ) 
	then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local RB = Vector(-7200,-6666)
	local DB = Vector(7137,6548)
	
	-- Get some of its values
	local nRadius = abilityOrb:GetSpecialValueInt( "radius" );
	local nCastRange = abilityOrb:GetCastRange();
	local nDamage = abilityOrb:GetAbilityDamage();
	
	nCastRange = 1600;
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				local loc = mutil.GetEscapeLoc();
				return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsTowardsLocation( loc, nCastRange );
			end
		end
	end
	
	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();

		if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastIllusoryOrbOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
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
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange/2, nRadius, 0, 0 );
		if ( locationAoE.count >= 4 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	-- If mana is full and we're laning just hit hero
	if ( npcBot:GetActiveMode() == BOT_MODE_LANING and 
		npcBot:GetMana() == npcBot:GetMaxMana() ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		if(tableNearbyEnemyHeroes[1] ~= nil) then
			return BOT_ACTION_DESIRE_LOW, tableNearbyEnemyHeroes[1]:GetLocation();
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

----------------------------------------------------------------------------------------------------

function ConsiderWaningRift()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilitySilence:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- If we want to cast priorities at all, bail
	if ( castPhaseDesire > 0 or castCoilDesire > 50) then
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nRadius = abilitySilence:GetSpecialValueInt( "radius" );
	local nCastRange = 0;
	local nDamage = abilitySilence:GetAbilityDamage();

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
	if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes  >= 3 
	then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and CanCastWaningRiftOnTarget( npcEnemy )  ) 
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
		if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastWaningRiftOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nRadius ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end


----------------------------------------------------------------------------------------------------

function ConsiderEtherealJaunt()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityJaunt:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil ) then
			local pro = GetLinearProjectiles();
			for _,pr in pairs(pro)
			do
				if pr.ability:GetName() == "puck_illusory_orb" then
					local ProjDist = GetUnitToLocationDistance(npcTarget, pr.location);
					if ProjDist < pr.radius then
						return BOT_ACTION_DESIRE_MODERATE;
					end
				end	
			end
		end
		
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local pro = GetLinearProjectiles();
		for _,pr in pairs(pro)
		do
			if pr.ability:GetName() == "puck_illusory_orb" then
				local ProjDist = utils.GetDistance(illuOrbLoc, pr.location);
				if ProjDist < 100 then
					return BOT_ACTION_DESIRE_MODERATE;
				end
			end	
		end	
	end
	
	return BOT_ACTION_DESIRE_NONE;

end

----------------------------------------------------------------------------------------------------

function ConsiderPhaseShift()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityPhase:IsFullyCastable() and not npcBot:HasModifier("modifier_puck_phase_shift") ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nDuration = abilityPhase:GetSpecialValueFloat("duration");

	if npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH  then
		local incProj = npcBot:GetIncomingTrackingProjectiles()
		for _,p in pairs(incProj)
		do
			if GetUnitToLocationDistance(npcBot, p.location) < 200 and ( p.is_attack or p.is_dodgeable ) then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	
	if npcBot:GetActiveMode() == BOT_MODE_LANING then
		local incProj = npcBot:GetIncomingTrackingProjectiles()
		for _,p in pairs(incProj)
		do
			if GetUnitToLocationDistance(npcBot, p.location) < 200 and ( p.is_attack or p.is_dodgeable ) then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local incProj = npcBot:GetIncomingTrackingProjectiles()
		for _,p in pairs(incProj)
		do
			if GetUnitToLocationDistance(npcBot, p.location) < 200 and ( p.is_attack or p.is_dodgeable ) then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

----------------------------------------------------------------------------------------------------

function ConsiderDreamCoil()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityCoil:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityCoil:GetCastRange();
	local nInitDamage = abilityCoil:GetSpecialValueInt( "coil_init_damage_tooltip" );
	local nBreakDamage = abilityCoil:GetSpecialValueInt( "coil_break_damage" );
	local nRadius = abilityCoil:GetSpecialValueInt( "coil_radius" );

	-- If enemy is channeling cancel it
	local npcTarget = npcBot:GetTarget();
	if (npcTarget ~= nil and npcTarget:IsChanneling() and GetUnitToUnitDistance( npcTarget, npcBot ) < ( nCastRange + nRadius ))
	then
		return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
	end
	-- If a mode has set a target, and we can kill them, do it
	if ( npcTarget ~= nil and CanCastDreamCoilOnTarget( npcTarget ) )
	then
		if ( npcTarget:GetActualIncomingDamage( nInitDamage + nBreakDamage, 2 ) > npcTarget:GetHealth() and GetUnitToUnitDistance( npcTarget, npcBot ) < ( nCastRange + nRadius ) )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
		end
	end

	-- If we're in a teamfight, use it on the scariest enemy
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then

		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );

		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	-- If an enemy is under our tower...
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + nRadius, true, BOT_MODE_NONE );
	local tableNearbyFriendlyTowers = npcBot:GetNearbyTowers( 1300, false );
	if tower ~= nil then
		for _,npcTarget in pairs(tableNearbyEnemyHeroes) do
			if ( GetUnitToUnitDistance( npcTarget, tower ) < 1100 ) 
			then
				if(npcTarget:IsFacingUnit( tower, 15 ) and npcTarget:HasModifier("modifier_puck_coiled") ) then
					return BOT_ACTION_DESIRE_MODERATE, npcBot:GetXUnitsTowardsLocation( npcTarget:GetLocation(), nCastRange - 1);
				end
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE, 0;

end

----------------------------------------------------------------------------------------------------

function ConsiderBlinkInit()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityOrb:IsFullyCastable() or
		not abilitySilence:IsFullyCastable() or
		not abilityPhase:IsFullyCastable()) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityOrb:GetCastRange();
	local nRadius = abilitySilence:GetSpecialValueInt( "radius" );

	-- Find a big group to nuke

	local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), 1300, nRadius, 0, 0 );
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
	local npcTarget = tableNearbyEnemyHeroes[1];	
	if npcTarget ~= nil then
		if ( locationAoE.count >= 3 and GetUnitToLocationDistance( npcTarget, locationAoE.targetloc ) < nRadius ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;

end
----------------------------------------------------------------------------------------------------

function ConsiderForceEnemy()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( itemForce == "item_force_staff" or not itemForce:IsFullyCastable()) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = 800;
	local nPushRange = 600;

	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
	local tableNearbyFriendlyTowers = npcBot:GetNearbyTowers( 1300, false );
	if tower ~= nil then
		for _,npcTarget in pairs(tableNearbyEnemyHeroes) do
			if ( GetUnitToUnitDistance( npcTarget, tower ) < 1100 ) 
			then
				if(npcTarget:IsFacingEntity( tower, 15 ) and npcTarget:HasModifier("modifier_puck_coiled") ) then
					return BOT_ACTION_DESIRE_MODERATE, npcTarget;
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;

end

----------------------------------------------------------------------------------------------------

function performBlinkInit( castBlinkInitTarget )
	local npcBot = GetBot();
	local orbTarget = npcBot:GetLocation();

	if( itemBlink ~= "item_blink" and itemBlink:IsFullyCastable()) then
		npcBot:Action_UseAbilityOnLocation( itemBlink, castBlinkInitTarget);
	end
end

----------------------------------------------------------------------------------------------------

function performForceEnemy( castForceEnemyTarget )
	local npcBot = GetBot();
	npcBot:Action_UseAbilityOnEntity( itemForce, castForceEnemyTarget );
end

----------------------------------------------------------------------------------------------------
