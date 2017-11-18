if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
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


local castDCDesire = 0;
local castIGDesire = 0;
local castFBDesire = 0;
local castOODesire = 0;

local abilityIG = nil;
local abilityFB = nil;
local abilityDC = nil;
local abilityOO = nil;

local threshold = 0.25;
local npcBot = nil;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	--print(npcBot:GetActiveMode())
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end

	if abilityIG == nil then abilityIG = npcBot:GetAbilityByName( "techies_land_mines" ) end
	if abilityFB == nil then abilityFB = npcBot:GetAbilityByName( "techies_stasis_trap" ) end
	if abilityDC == nil then abilityDC = npcBot:GetAbilityByName( "techies_suicide" ) end
	if abilityOO == nil then abilityOO = npcBot:GetAbilityByName( "techies_remote_mines" ) end
	
	-- Consider using each ability
	castDCDesire, castDCLocation = ConsiderDecay();
	castOODesire, castOOLocation = ConsiderOverwhelmingOdds();
	castIGDesire, castIGTarget = ConsiderIgnite();
	castFBDesire, castFBTarget = ConsiderFireblast();
	
	castSoulRing();
	
	if ( castIGDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityIG, castIGTarget );
		return;
	end
	
	if ( castOODesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityOO, castOOLocation );
		return;
	end
	
	if ( castDCDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityDC, castDCLocation );
		return;
	end
	
	if ( castFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityFB, castFBTarget );
		return;
	end

	
end

function SoulRingAvailable()
    for i = 0, 5 
	do
        local item = npcBot:GetItemInSlot(i);
		if (item~=nil) then
			if(item:GetName() == "item_soul_ring") then
				return item;
			end
		end
    end
    return nil;
end

function castSoulRing()
	local sr=SoulRingAvailable()
    if sr~=nil and sr:IsFullyCastable() and npcBot:GetHealth() > 2 * 150
	then
		local currManaRatio = npcBot:GetMana() / npcBot:GetMaxMana();
		if ( abilityIG:IsCooldownReady() or  abilityFB:IsCooldownReady() or  abilityDC:IsCooldownReady() or  abilityOO:IsCooldownReady() ) and
			currManaRatio < 0.75
		then	
			npcBot:Action_UseAbility(sr);
			return
		end
	end
end

function InRadius(uType, nRadius, vLocation)
	local unit = GetUnitList(UNIT_LIST_ALLIED_OTHER);
	if uType == "mines" then
		for _,u in pairs (unit)
		do
			if u:GetUnitName() == "npc_dota_techies_land_mine"
			then
				if GetUnitToLocationDistance(u, vLocation) <= nRadius then
					return true;
				end
			end
		end
	elseif uType == "traps" then
		for _,u in pairs (unit)
		do
			if u:GetUnitName() == "npc_dota_techies_stasis_trap"
			then
				if GetUnitToLocationDistance(u, vLocation) <= nRadius then
					return true;
				end
			end
		end
	end
	return false;
end

function ConsiderIgnite()
	
	-- Make sure it's castable
	if ( not abilityIG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nRadius = abilityIG:GetSpecialValueInt('radius')+20;
	local nCastRange = abilityIG:GetCastRange();
	local vLocation = npcBot:GetXUnitsInFront(nCastRange)+RandomVector(200);
	
	local currManaRatio = npcBot:GetMana() / npcBot:GetMaxMana();
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and not InRadius("mines", nRadius, vLocation)  ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcBot:GetXUnitsInFront(nCastRange);
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	if mutil.IsPushing(npcBot)
	then
		local tableNearbyEnemyTowers = npcBot:GetNearbyTowers( 800, true );
		if tableNearbyEnemyTowers ~= nil and #tableNearbyEnemyTowers > 0 and not tableNearbyEnemyTowers[1]:IsInvulnerable()
		then
			local loc = tableNearbyEnemyTowers[1]:GetLocation()+RandomVector(300);
			if not InRadius("mines", nRadius, loc) then
				return BOT_ACTION_DESIRE_MODERATE, loc;
			end
		end
	end
	
	if mutil.IsDefending(npcBot)
	then
		local tableNearbyAllyTowers = npcBot:GetNearbyTowers( 800, false );
		if tableNearbyAllyTowers ~= nil and #tableNearbyAllyTowers > 0 and not tableNearbyAllyTowers[1]:IsInvulnerable() 
		then
			local loc = tableNearbyAllyTowers[1]:GetLocation()+RandomVector(300);
			if not InRadius("mines", nRadius, loc) then
				return BOT_ACTION_DESIRE_MODERATE, loc;
			end
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();

		if (  mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) ) 
		then
			local loc = npcTarget:GetLocation();
			if not InRadius("mines", nRadius, loc) then
				return BOT_ACTION_DESIRE_MODERATE, loc;
			end
		end
	end
	
	
	if not InRadius("mines", nRadius, vLocation) and currManaRatio > threshold and npcBot:DistanceFromFountain() > 1500 and DotaTime() > 0 then
		return BOT_ACTION_DESIRE_LOW, vLocation;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderFireblast()

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	local nRadius = 620;
	local nCastRange = abilityFB:GetCastRange();
	local vLocation = npcBot:GetXUnitsInFront(nCastRange)+RandomVector(200);
	
	local currManaRatio = npcBot:GetMana() / npcBot:GetMaxMana();
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_LOW, npcBot:GetXUnitsInFront(nCastRange);
			end
		end
	end
	
	if mutil.IsDefending(npcBot)
	then
		local tableNearbyAllyTowers = npcBot:GetNearbyTowers( 800, false );
		if tableNearbyAllyTowers ~= nil and #tableNearbyAllyTowers > 0 and not tableNearbyAllyTowers[1]:IsInvulnerable() then
			local loc = tableNearbyAllyTowers[1]:GetLocation()+RandomVector(300);
			if not InRadius("traps", nRadius, loc) then
				return BOT_ACTION_DESIRE_MODERATE, loc;
			end
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if (  mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) ) 
		then
			local loc = npcTarget:GetLocation();
			if not InRadius("traps", nRadius, loc) then
				return BOT_ACTION_DESIRE_MODERATE, loc;
			end
		end
	end
	
	
	if not InRadius("traps", nRadius, vLocation) and currManaRatio > threshold and npcBot:DistanceFromFountain() > 1500 and DotaTime() > 0 then
		return BOT_ACTION_DESIRE_LOW, vLocation;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderDecay()

	-- Make sure it's castable
	if ( not abilityDC:IsFullyCastable() or npcBot:IsRooted() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nRadius = abilityDC:GetSpecialValueInt( "radius" );
	local nCastRange = abilityDC:GetCastRange();
	local nCastPoint = abilityDC:GetCastPoint( );
	local nDamage = abilityDC:GetSpecialValueInt("damage");
	local nHPP = npcBot:GetHealth() / npcBot:GetMaxHealth();

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if nHPP >= 0.65 then
					return BOT_ACTION_DESIRE_LOW, npcBot:GetXUnitsInFront(nCastRange);
				else
					return BOT_ACTION_DESIRE_LOW, npcEnemy:GetLocation();
				end
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if  mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
		then
			local EnemyHeroes = npcTarget:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			if ( #EnemyHeroes >= 1 )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
			end
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderOverwhelmingOdds()

	-- Make sure it's castable
	if ( not abilityOO:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local npcBot = GetBot();
	
	local nCastRange = abilityOO:GetCastRange();
	local vLocation = npcBot:GetXUnitsInFront(nCastRange);

	
	local currManaRatio = npcBot:GetMana() / npcBot:GetMaxMana();
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcBot:GetXUnitsInFront(nCastRange);
			end
		end
	end
	
	if mutil.IsPushing(npcBot)
	then
		local tableNearbyEnemyTowers = npcBot:GetNearbyTowers( 800, true );
		if tableNearbyEnemyTowers ~= nil and #tableNearbyEnemyTowers > 0 and not tableNearbyEnemyTowers[1]:IsInvulnerable() then
			return BOT_ACTION_DESIRE_MODERATE, tableNearbyEnemyTowers[1]:GetLocation() + RandomVector(300);
		end
	end
	
	if mutil.IsDefending(npcBot)
	then
		local tableNearbyAllyTowers = npcBot:GetNearbyTowers( 800, false );
		if tableNearbyAllyTowers ~= nil and #tableNearbyAllyTowers > 0 and not tableNearbyAllyTowers[1]:IsInvulnerable() then
			return BOT_ACTION_DESIRE_LOW, tableNearbyAllyTowers[1]:GetLocation() + RandomVector(300);
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if (  mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) ) 
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end

	if  currManaRatio > threshold and npcBot:DistanceFromFountain() > 1000 then
		return BOT_ACTION_DESIRE_LOW, vLocation;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
