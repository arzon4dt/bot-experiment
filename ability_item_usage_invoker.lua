local bot = GetBot();

if bot:IsInvulnerable() or bot:IsHero() == false or bot:IsIllusion() then return; end

local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local mutils = require(GetScriptDirectory() ..  "/MyUtility")

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

-- "Ability1"		"invoker_quas"				1
-- "Ability2"		"invoker_wex"				2
-- "Ability3"		"invoker_exort"				3
-- "Ability4"		"invoker_empty1"
-- "Ability5"		"invoker_empty2"
-- "Ability6"		"invoker_invoke"			4
-- "Ability7"		"invoker_cold_snap"			5
-- "Ability8"		"invoker_ghost_walk"		6
-- "Ability9"		"invoker_tornado"			7
-- "Ability10"		"invoker_emp"				8
-- "Ability11"		"invoker_alacrity"			9
-- "Ability12"		"invoker_chaos_meteor"		10
-- "Ability13"		"invoker_sun_strike"		11
-- "Ability14"		"invoker_forge_spirit"		12
-- "Ability15"		"invoker_ice_wall"			13
-- "Ability16"		"invoker_deafening_blast"	14		
-------------------------------------------------1,2,3,4,5,6,7,8,9 ,10,11,12,13,14,15
local abilities = mutils.InitiateAbilities(bot, {0,1,2,5,6,7,8,9,10,11,12,13,14,15,16});

local castAlacrityDesire = 0;
local castChaosMeteorDesire = 0;
local castColdSnapDesire = 0;
local castDeafeningBlastDesire = 0;
local castEMPDesire = 0;
local castForgeSpiritDesire = 0;
local castGhostWalkDesire = 0;
local castIceWallDesire = 0;
local castSunStrikeDesire = 0;
local castTornadoDesire = 0;

local Q = 1;
local W = 2;
local E = 3;

local empDelay = 2.9;
local tornadoLift = 0;
local sunstrikeDelay = 2;
local chaosmeteorDelay = 1.3;
local tornadoCastTime = -90;
local empCastTime = -90;
local chaosmeteorCastTime = -90;
local sunstrikeCastTime = -90;
local deafeningblastCastTime = -90;

local function IsOrbTrained(orb)
	return orb:IsTrained();
end

local function IsAbilityHidden(skill)
	return skill:IsHidden();
end

local function InvokeOrbToSpell(orb1, orb2, orb3)
    if  mutils.CanBeCast(abilities[4]) == false then
		return BOT_ACTION_DESIRE_NONE;
	end

    bot:ActionPush_UseAbility( abilities[4] )
    bot:ActionPush_UseAbility( abilities[orb1] )
    bot:ActionPush_UseAbility( abilities[orb2] )
    bot:ActionPush_UseAbility( abilities[orb3] )
	
    return true
end

local function CombineOrb(orb1, orb2, orb3)
   
    bot:ActionPush_UseAbility( abilities[orb1] )
    bot:ActionPush_UseAbility( abilities[orb2] )
    bot:ActionPush_UseAbility( abilities[orb3] )
	
    return true
end

local function ConsiderEarlySpells()
	 if bot:GetLevel() == 1 then
		if IsOrbTrained(abilities[3]) == true and IsAbilityHidden(abilities[11]) == true then
			InvokeOrbToSpell(E, E, E)
			return
		elseif IsOrbTrained(abilities[1]) == true and IsAbilityHidden(abilities[5]) == true then
			InvokeOrbToSpell(Q, Q, Q)
			return
		elseif IsOrbTrained(abilities[2]) == true and IsAbilityHidden(abilities[8]) == true then
			InvokeOrbToSpell(W, W, W)
			return	
		end
    elseif bot:GetLevel() == 2 then
		if IsOrbTrained(abilities[1]) == true and IsOrbTrained(abilities[3]) == true and IsAbilityHidden(abilities[5]) == true then
			CombineOrb(E, E, E) -- this is first since we are pushing, not queueing
			InvokeOrbToSpell(Q, Q, Q)
			return
		elseif IsOrbTrained(abilities[1]) == true and IsOrbTrained(abilities[2]) == true and IsAbilityHidden(abilities[8]) == true then 
			CombineOrb(W, W, W) -- this is first since we are pushing, not queueing
			InvokeOrbToSpell(W, W, W)
			return
		end	
    end
end

local function ConsiderAlacrity()
	if mutils.CanBeCast(abilities[2]) == false 
		or mutils.CanBeCast(abilities[3]) == false 
		or mutils.CanBeCast(abilities[4]) == false 
		or abilities[9]:IsFullyCastable() == false 
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end	
	
	local nCastPoint = abilities[9]:GetCastPoint();
	local manaCost   = abilities[9]:GetManaCost();
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[9]:GetCastRange());
	local nAttackRange = bot:GetAttackRange();
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) )
		and  mutils.CanSpamSpell(bot, manaCost) 
		and  mutils.CanCastOnNonMagicImmune(bot) 
	then
		local creeps = bot:GetNearbyLaneCreeps(nAttackRange+200, true);
		if creeps ~= nil and #creeps >= 3 then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end
		local towers = bot:GetNearbyTowers(nAttackRange+200, true);
		if towers ~= nil and #towers > 0 then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end
	end
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN and  mutils.CanSpamSpell(bot, manaCost)  ) 
	then
		local target = bot:GetAttackTarget();
		if ( mutils.IsRoshan(target) and mutils.IsInRange(target, bot, 400) and mutils.CanCastOnNonMagicImmune(bot)  )
		then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnMagicImmune(target) 
			and mutils.IsInRange(bot, target, nAttackRange+100) == true	
			and mutils.CanCastOnNonMagicImmune(bot) 
		then	
			return BOT_ACTION_DESIRE_HIGH, bot;
		end
	end	
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

local function ConsiderChaosMeteor()
	if mutils.CanBeCast(abilities[2]) == false 
		or mutils.CanBeCast(abilities[3]) == false 
		or mutils.CanBeCast(abilities[4]) == false 
		or abilities[10]:IsFullyCastable() == false 
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end	
	
	local nCastPoint = abilities[10]:GetCastPoint();
	local manaCost   = abilities[10]:GetManaCost();
	local nRadius    = abilities[10]:GetSpecialValueInt('area_of_effect');
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[10]:GetCastRange());
	
	if mutils.IsInTeamFight(bot, 1300) and DotaTime() > tornadoCastTime + tornadoLift then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2  ) 
		then
			local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE) ;
			local nUnits = mutils.CountUnitsNearLocation(false, enemies, locationAoE.targetloc, nRadius)
			if nUnits >= locationAoE.count then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end	
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) and DotaTime() > tornadoCastTime + tornadoLift
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(bot, target, nCastRange) == true	
		then
			local enemies = target:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE);
			if enemies ~= nil and #enemies >= 2 then
				return BOT_ACTION_DESIRE_LOW, target:GetLocation();
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

local function ConsiderColdSnap()
	if mutils.CanBeCast(abilities[1]) == false 
		or mutils.CanBeCast(abilities[4]) == false 
		or abilities[5]:IsFullyCastable() == false 
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end	
	
	local nCastPoint = abilities[5]:GetCastPoint();
	local manaCost   = abilities[5]:GetManaCost();
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[5]:GetCastRange());
	
	if ( mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) )
	then
		local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		if enemies ~= nil and #enemies == 0 then
			local allies = bot:GetNearbyHeroes(1300, false, BOT_MODE_ATTACK);
			if allies ~= nil and #allies > 0 then 
				local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
				if target ~= nil then
					return BOT_ACTION_DESIRE_HIGH, target;
				end
			end	
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(target, bot, nCastRange)
			and mutils.IsDisabled(true, target) == false
		then
			return BOT_ACTION_DESIRE_MODERATE, target;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

local function ConsiderDeafeningBlast()
	if mutils.CanBeCast(abilities[1]) == false 
		or mutils.CanBeCast(abilities[2]) == false 
		or mutils.CanBeCast(abilities[3]) == false 
		or mutils.CanBeCast(abilities[4]) == false 
		or abilities[14]:IsFullyCastable() == false 
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end	
	
	local nCastPoint = abilities[14]:GetCastPoint();
	local manaCost   = abilities[14]:GetManaCost();
	local nRadius    = abilities[14]:GetSpecialValueInt('radius_end');
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[14]:GetCastRange());
	
	if ( mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) ) 
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange-200, nRadius, 0, 0 );
		if ( locationAoE.count >= 2  ) 
		then
			local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE) ;
			local nUnits = mutils.CountUnitsNearLocation(false, enemies, locationAoE.targetloc, nRadius)
			if nUnits >= locationAoE.count then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end	
		end
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
		end
	end
	
	if mutils.IsInTeamFight(bot, 1300) and DotaTime() > tornadoCastTime + tornadoLift 
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange-200, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE) ;
			local nUnits = mutils.CountUnitsNearLocation(false, enemies, locationAoE.targetloc, nRadius)
			if nUnits >= locationAoE.count then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end	
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) and DotaTime() > tornadoCastTime + tornadoLift
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(bot, target, nCastRange-200) == true	
		then
			local enemies = target:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE);
			if enemies ~= nil and #enemies >= 2 then
				return BOT_ACTION_DESIRE_LOW, target:GetLocation();
			end
			if mutils.IsDisabled(true, target) == false and ( bot:GetAttackTarget() ~= nil or bot:GetTarget() ~= nil )
			then
				return BOT_ACTION_DESIRE_LOW, target:GetLocation();
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

local function ConsiderEMP()
	if mutils.CanBeCast(abilities[2]) == false 
		or mutils.CanBeCast(abilities[4]) == false 
		or abilities[8]:IsFullyCastable() == false 
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end	
	
	local nCastPoint = abilities[8]:GetCastPoint();
	local manaCost   = abilities[8]:GetManaCost();
	local nRadius    = abilities[8]:GetSpecialValueInt('area_of_effect');
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[8]:GetCastRange());
	
	if ( mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) )
	then
		local enemies = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
		if enemies ~= nil and #enemies > 0 then
			local allies = bot:GetNearbyHeroes(1200, false, BOT_MODE_ATTACK);
			if allies ~= nil and #allies > 0 then 
				return BOT_ACTION_DESIRE_HIGH, bot:GetLocation();
			end	
		end
	end
	
	if mutils.IsInTeamFight(bot, 1300) and DotaTime() > tornadoCastTime + tornadoLift - empDelay
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE) ;
			local nUnits = mutils.CountUnitsNearLocation(false, enemies, locationAoE.targetloc, nRadius)
			if nUnits >= locationAoE.count then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end	
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) and DotaTime() > tornadoCastTime + tornadoLift - empDelay
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(target, bot, nCastRange)
			and mutils.IsDisabled(true, target) == true
		then
			return BOT_ACTION_DESIRE_MODERATE, target:GetLocation();
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

local function ConsiderForgeSpirit()
	if mutils.CanBeCast(abilities[1]) == false 
		or mutils.CanBeCast(abilities[3]) == false 
		or mutils.CanBeCast(abilities[4]) == false 
		or abilities[12]:IsFullyCastable() == false 
	then
		return BOT_ACTION_DESIRE_NONE;
	end	
	
	local manaCost   = abilities[12]:GetManaCost();
	local nAttackRange = bot:GetAttackRange();
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and  mutils.CanSpamSpell(bot, manaCost) 
	then
		local creeps = bot:GetNearbyLaneCreeps(nAttackRange+100, true);
		if creeps ~= nil and #creeps >= 3 then
			return BOT_ACTION_DESIRE_HIGH;
		end
		local towers = bot:GetNearbyTowers(nAttackRange+100, true);
		if towers ~= nil and #towers > 0 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN and  mutils.CanSpamSpell(bot, manaCost)  ) 
	then
		local target = bot:GetAttackTarget();
		if ( mutils.IsRoshan(target) and mutils.IsInRange(target, bot, 400) )
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnMagicImmune(target) 
			and mutils.IsInRange(bot, target, nAttackRange+100) == true	
		then	
			return BOT_ACTION_DESIRE_HIGH;
		end
	end	
	
	return BOT_ACTION_DESIRE_NONE;
end

local function ConsiderGhostWalk()
	if mutils.CanBeCast(abilities[1]) == false 
		or mutils.CanBeCast(abilities[2]) == false 
		or mutils.CanBeCast(abilities[4]) == false 
		or abilities[6]:IsFullyCastable() == false 
	then
		return BOT_ACTION_DESIRE_NONE;
	end	
	
	if ( mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) )
	then
		local enemies = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE);
		if enemies ~= nil and #enemies > 0 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

local function ConsiderIceWall()
	if mutils.CanBeCast(abilities[1]) == false 
		or mutils.CanBeCast(abilities[3]) == false 
		or mutils.CanBeCast(abilities[4]) == false 
		or abilities[13]:IsFullyCastable() == false 
	then
		return BOT_ACTION_DESIRE_NONE;
	end	
	
	local nCastPoint = abilities[13]:GetCastPoint();
	local manaCost   = abilities[13]:GetManaCost();
	local nRadius    = abilities[13]:GetSpecialValueInt('wall_element_radius');
	local nCastRange = abilities[13]:GetSpecialValueInt('wall_place_distance');
	
	if ( mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) )
	then
		local enemies = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE);
		if enemies ~= nil and #enemies > 0 then
			local loc = mutils.GetEscapeLoc2(bot);
			if  bot:IsFacingLocation(loc,15) then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	if mutils.IsInTeamFight(bot, 1300)
	then
		local enemies = bot:GetNearbyHeroes(nCastRange+nRadius, true, BOT_MODE_NONE) ;
		for i=1, #enemies do
			if mutils.IsValidTarget(enemies[i])
				and mutils.CanCastOnMagicImmune(enemies[i])
				and mutils.IsInRange(bot, enemies[i], nCastRange+nRadius)
				and bot:IsFacingLocation(enemies[i]:GetLocation(), 15) 
			then
				return BOT_ACTION_DESIRE_ABSOLUTE;
			end	
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(bot, target, nCastRange+nRadius) == true	
			and bot:IsFacingLocation(target:GetLocation(),15) 
		then	
			return BOT_ACTION_DESIRE_HIGH;
		end
	end	
	
	return BOT_ACTION_DESIRE_NONE;
end

local function ConsiderSunStrike()
	if mutils.CanBeCast(abilities[3]) == false 
		or mutils.CanBeCast(abilities[4]) == false 
		or abilities[11]:IsFullyCastable() == false 
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end	
	
    local nRadius = abilities[11]:GetSpecialValueInt( "area_of_effect" );
    local nDelay = 2;
	local exortLvl = abilities[3]:GetLevel();
    local nDamage = 37.5 + exortLvl*62.5;
	
	if bot:HasScepter() == false then
		local globalEnemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
		for _,enemy in pairs(globalEnemies) do
			if mutils.IsValidTarget(enemy) 
				and mutils.CanCastOnMagicImmune(enemy) 
				and enemy:GetHealth() < nDamage
			then
				if mutils.IsDisabled(true, enemy) == true then
					return BOT_ACTION_DESIRE_MODERATE, enemy:GetLocation()
				else
					local pLoc = enemy:GetExtrapolatedLocation( nDelay );
					local moveCon = enemy:GetMovementDirectionStability();
					if moveCon < 0.65 then
						pLoc = enemy:GetLocation();
					end
					return BOT_ACTION_DESIRE_MODERATE, pLoc, 'point';
				end
			end
		end
		
		if mutils.IsGoingOnSomeone(bot) and DotaTime() > tornadoCastTime + tornadoLift - sunstrikeDelay
		then
			local target = bot:GetTarget();
			if mutils.IsValidTarget(target) 
				and mutils.CanCastOnMagicImmune(target) 
			then	
				if mutils.IsDisabled(true, target) == true then
					return BOT_ACTION_DESIRE_MODERATE, target:GetLocation()
				else
					local pLoc = target:GetExtrapolatedLocation( nDelay );
					local moveCon = target:GetMovementDirectionStability();
					if moveCon < 0.65 then
						pLoc = target:GetLocation();
					end
					return BOT_ACTION_DESIRE_MODERATE, pLoc, 'point';
				end
			end	
		end
	else
		if mutils.IsInTeamFight(bot, 1300)
		then
			local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
			local nStunned = 0;
			for i=1, #enemies do
				if mutils.IsValidTarget(enemies[i])
					and mutils.CanCastOnMagicImmune(enemies[i])
					and ( enemies[i]:IsStunned() 
						or enemies[i]:IsRooted()
						or enemies[i]:GetCurrentMovementSpeed() < enemies[i]:GetBaseMovementSpeed() )
				then
					nStunned = nStunned + 1;
				end
			end
			if nStunned > 1 then
				return BOT_ACTION_DESIRE_MODERATE, nil, 'no_target';
			end
		end
		
		if mutils.IsGoingOnSomeone(bot) 
		then
			local target = bot:GetTarget();
			if mutils.IsValidTarget(target) 
				and mutils.CanCastOnMagicImmune(target) 
				and ( target:IsStunned() 
						or target:IsRooted()
						or target:GetCurrentMovementSpeed() < target:GetBaseMovementSpeed() )
			then	
				return BOT_ACTION_DESIRE_MODERATE, nil, 'no_target';
			end	
		end
	end

   
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

local function ConsiderTornado()
	if mutils.CanBeCast(abilities[1]) == false 
		or mutils.CanBeCast(abilities[2]) == false 
		or mutils.CanBeCast(abilities[4]) == false 
		or abilities[7]:IsFullyCastable() == false 
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end	
	
	local nCastPoint = abilities[7]:GetCastPoint();
	local manaCost   = abilities[7]:GetManaCost();
	local nRadius    = abilities[7]:GetSpecialValueInt('area_of_effect');
	local nSpeed    = abilities[7]:GetSpecialValueInt('travel_speed');
	local wexLvl	 = abilities[2]:GetLevel();
	local nCastRange = mutils.GetProperCastRange(false, bot, 400+wexLvl*400);
	tornadoLift = 0.5+0.3*abilities[1]:GetLevel();
	
	if ( mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) )
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2  ) 
		then
			local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE) ;
			local nUnits = mutils.CountUnitsNearLocation(false, enemies, locationAoE.targetloc, nRadius)
			if nUnits >= locationAoE.count then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, GetUnitToLocationDistance(bot, locationAoE.targetloc)/nSpeed;
			end	
		end
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation(), GetUnitToUnitDistance(bot, target)/nSpeed;
		end
	end
	
	if mutils.IsInTeamFight(bot, 1300) and DotaTime() > empCastTime + empDelay 
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE) ;
			local nUnits = mutils.CountUnitsNearLocation(false, enemies, locationAoE.targetloc, nRadius)
			if nUnits >= locationAoE.count then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, GetUnitToLocationDistance(bot, locationAoE.targetloc)/nSpeed;
			end	
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) and DotaTime() > empCastTime + empDelay and DotaTime() > sunstrikeCastTime + sunstrikeDelay
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(bot, target, nCastRange) == true	
		then
			local enemies = target:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE);
			if enemies ~= nil and #enemies >= 2 then
				return BOT_ACTION_DESIRE_LOW, target:GetLocation(), GetUnitToUnitDistance(bot, target)/nSpeed;
			end
			if mutils.IsDisabled(true, target) == false and ( bot:GetAttackTarget() ~= nil or bot:GetTarget() ~= nil )
			then
				return BOT_ACTION_DESIRE_LOW, target:GetLocation(), GetUnitToUnitDistance(bot, target)/nSpeed;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

local function ConsiderOrbs()
    local botModifierCount = bot:NumModifiers()
    local nQuas = 0
    local nWex = 0
    local nExort = 0
    
    for i = 0, botModifierCount-1, 1 do
        local modName = bot:GetModifierName(i)
        if modName == "modifier_invoker_wex_instance" then
            nWex = nWex + 1
        elseif modName == "modifier_invoker_quas_instance" then
            nQuas = nQuas + 1
        elseif modName == "modifier_invoker_exort_instance" then
            nExort = nExort + 1
        end
        
        if (nWex + nQuas + nExort) >= 3 then break end
    end
    
    if mutils.IsRetreating(bot) 
		and bot:WasRecentlyDamagedByAnyHero(5.0) 
		and mutils.CanBeCast(abilities[2])  
		and ( bot:HasModifier('modifier_maledict_dot') or bot:HasModifier('modifier_maledict') )
	then
		if nQuas < 3 then
            CombineOrb(Q, Q, Q)
            return true
        end
    elseif mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) and mutils.CanBeCast(abilities[2])  then
        if nWex < 3 then 
            CombineOrb(W, W, W)
            return true
        end
    elseif bot:GetHealth() < 0.75*bot:GetMaxHealth() and mutils.CanBeCast(abilities[1]) then
        if nQuas < 3 then
            CombineOrb(Q, Q, Q)
            return true
        end
	elseif mutils.IsGoingOnSomeone(bot) then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnMagicImmune(target) 
			and mutils.IsInRange(bot, target, 1000) == true	
		then
			if bot:HasModifier('modifier_invoker_alacrity') == false and mutils.CanBeCast(abilities[2]) then
				if nWex < 3 then 
					CombineOrb(W, W, W)
					return true
				end
			else
				if nExort < 3 and mutils.CanBeCast(abilities[3]) and mutils.CanBeCast(abilities[3]) then
					CombineOrb(E, E, E)
					return true
				end
			end
		end	
    else
        if nWex < 3 and mutils.CanBeCast(abilities[2]) then
            CombineOrb(W, W, W)
            return true
        end
    end
    
    return false
end

local function ConsiderShowUp()
	if bot:HasModifier('modifier_invoker_ghost_walk_self') then
		local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
		if enemies == nil or #enemies == 0 or bot:HasModifier("modifier_item_dust") then
			InvokeOrbToSpell(W, W, W)
			return true
		end	
	end
    
    return false
end

function AbilityUsageThink()
	
	if mutils.CantUseAbility(bot) then return end
	
	ConsiderEarlySpells();
	
	castAlacrityDesire, alacrityTarget 				= ConsiderAlacrity();
	castChaosMeteorDesire, chaosMeteorTarget 		= ConsiderChaosMeteor();
	castColdSnapDesire, coldSnapTarget 				= ConsiderColdSnap();
	castDeafeningBlastDesire, deafeningBlastTarget 	= ConsiderDeafeningBlast();
	castEMPDesire, empTarget 						= ConsiderEMP();
	castForgeSpiritDesire							= ConsiderForgeSpirit();
	castGhostWalkDesire							 	= ConsiderGhostWalk();
	castIceWallDesire					 			= ConsiderIceWall();
	castSunStrikeDesire, sunStrikeTarget, ssType	= ConsiderSunStrike();
	castTornadoDesire, tornadoTarget, eta			= ConsiderTornado();
	
	if bot:HasModifier("modifier_invoker_ghost_walk_self") == false then
	
		if castGhostWalkDesire > 0 then
			if IsAbilityHidden(abilities[6]) == false then
				bot:Action_UseAbility( abilities[6] );
				return true;
			elseif mutils.CanBeCast(abilities[4]) == true then
				bot:Action_ClearActions(false);
				InvokeOrbToSpell(Q, Q, W);
				bot:ActionQueue_UseAbility( abilities[6] );
				return true;
			end
		end
	
		if castTornadoDesire > 0 then
			if IsAbilityHidden(abilities[7]) == false then
				bot:Action_UseAbilityOnLocation( abilities[7], tornadoTarget );
				tornadoCastTime = DotaTime()+eta;
				return true;
			elseif mutils.CanBeCast(abilities[4]) == true then
				bot:Action_ClearActions(false);
				InvokeOrbToSpell(W, W, Q);
				bot:ActionQueue_UseAbilityOnLocation( abilities[7], tornadoTarget );
				tornadoCastTime = DotaTime()+eta;
				return true;
			end
		end
		
		if castChaosMeteorDesire > 0 then
			if IsAbilityHidden(abilities[10]) == false then
				bot:Action_UseAbilityOnLocation( abilities[10], chaosMeteorTarget );
				chaosmeteorCastTime = DotaTime();
				return true;
			elseif mutils.CanBeCast(abilities[4]) == true then
				bot:Action_ClearActions(false);
				InvokeOrbToSpell(E, E, W);
				bot:ActionQueue_UseAbilityOnLocation( abilities[10], chaosMeteorTarget );
				chaosmeteorCastTime = DotaTime();
				return true;
			end
		end
		
		if castDeafeningBlastDesire > 0 then
			if IsAbilityHidden(abilities[14]) == false then
				bot:Action_UseAbilityOnLocation( abilities[14], deafeningBlastTarget );
				deafeningblastCastTime = DotaTime();
				return true;
			elseif mutils.CanBeCast(abilities[4]) == true then
				bot:Action_ClearActions(false);
				InvokeOrbToSpell(Q, W, E);
				bot:ActionQueue_UseAbilityOnLocation( abilities[14], deafeningBlastTarget );
				deafeningblastCastTime = DotaTime();
				return true;
			end
		end
		
		if castEMPDesire > 0 then
			if IsAbilityHidden(abilities[8]) == false then
				bot:Action_UseAbilityOnLocation( abilities[8], empTarget );
				empCastTime = DotaTime();
				return true;
			elseif mutils.CanBeCast(abilities[4]) == true then
				bot:Action_ClearActions(false);
				InvokeOrbToSpell(W, W, W);
				bot:ActionQueue_UseAbilityOnLocation( abilities[8], empTarget );
				empCastTime = DotaTime();
				return true;
			end
		end
		
		if castColdSnapDesire > 0 then
			if IsAbilityHidden(abilities[5]) == false then
				bot:Action_UseAbilityOnEntity( abilities[5], coldSnapTarget );
				return true;
			elseif mutils.CanBeCast(abilities[4]) == true then
				bot:Action_ClearActions(false);
				InvokeOrbToSpell(Q, Q, Q);
				bot:ActionQueue_UseAbilityOnEntity( abilities[5], coldSnapTarget );
				return true;
			end
		end
		
		if castAlacrityDesire > 0 then
			if IsAbilityHidden(abilities[9]) == false then
				bot:Action_UseAbilityOnEntity( abilities[9], alacrityTarget );
				return true;
			elseif mutils.CanBeCast(abilities[4]) == true then
				bot:Action_ClearActions(false);
				InvokeOrbToSpell(W, W, E);
				bot:ActionQueue_UseAbilityOnEntity( abilities[9], alacrityTarget );
				return true;
			end
		end
		
		if castForgeSpiritDesire > 0 then
			if IsAbilityHidden(abilities[12]) == false then
				bot:Action_UseAbility( abilities[12] );
				return true;
			elseif mutils.CanBeCast(abilities[4]) == true then
				bot:Action_ClearActions(false);
				InvokeOrbToSpell(E, E, Q);
				bot:ActionQueue_UseAbility( abilities[12] );
				return true;
			end
		end
		
		if castSunStrikeDesire > 0 then
			if IsAbilityHidden(abilities[11]) == false then
				if ssType == 'point' then
					bot:Action_UseAbilityOnLocation( abilities[11], sunStrikeTarget );
				else
					bot:ActionPush_UseAbility( abilities[11] );
					bot:ActionPush_UseAbility( abilities[11] );
				end
				sunstrikeCastTime = DotaTime();
				return true;
			elseif mutils.CanBeCast(abilities[4]) == true then
				bot:Action_ClearActions(false);
				if ssType == 'point' then
					InvokeOrbToSpell(E, E, E);
					bot:ActionQueue_UseAbilityOnLocation( abilities[11], sunStrikeTarget );
				else
					bot:ActionQueue_UseAbility( abilities[11] );
					bot:ActionQueue_UseAbility( abilities[11] );
				end
				sunstrikeCastTime = DotaTime();
				return true;
			end
		end
		
		if castIceWallDesire > 0 then
			if IsAbilityHidden(abilities[13]) == false then
				bot:Action_UseAbility( abilities[13] );
				return true;
			elseif mutils.CanBeCast(abilities[4]) == true then
				bot:Action_ClearActions(false);
				InvokeOrbToSpell(Q, Q, E);
				bot:ActionQueue_UseAbility( abilities[13] );
				return true;
			end
		end
		
		local bRet = ConsiderOrbs()
		if bRet then return end
		
	end	

	bRet = ConsiderShowUp(bot, nearbyEnemyHeroes)
	
    if bRet then return end
	
    return false

end