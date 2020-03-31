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
function ItemUsageThink()
	ability_item_usage_generic.ItemUsageThink();
end

local castDCDesire = 0;
local castSPDesire = 0;
local castSPIDesire = 0;
local castSPODesire = 0;
local castOCDesire = 0;
local castRCDesire = 0;

local abilityDC = nil;
local abilitySP = nil;
local abilitySPI = nil;
local abilitySPO = nil;
local abilityOC = nil;
local abilityRC = nil;

local moveDesire = 0;
local npcBot = nil;

local spiritState = 1;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end

	if abilityDC == nil then abilityDC = npcBot:GetAbilityByName( "wisp_tether" ) end
	if abilitySP == nil then abilitySP = npcBot:GetAbilityByName( "wisp_spirits" ) end
	if abilitySPI == nil then abilitySPI = npcBot:GetAbilityByName( "wisp_spirits_in" ) end
	if abilitySPO == nil then abilitySPO = npcBot:GetAbilityByName( "wisp_spirits_in" ) end
	if abilityOC == nil then abilityOC = npcBot:GetAbilityByName( "wisp_overcharge" ) end
	if abilityRC == nil then abilityRC = npcBot:GetAbilityByName( "wisp_relocate" ) end

	-- Consider using each ability
	castDCDesire, castDCTarget = ConsiderDeathCoil();
	castSPDesire = ConsiderSpirits();
	castSPIDesire = ConsiderSpiritsIn();
	castSPODesire = ConsiderSpiritsOut();
	castOCDesire = ConsiderOverCharge();
	castRCDesire, castRCLocation = ConsiderRelocate();
	moveDesire, moveLocation = ConsiderMoving()

	if ( castRCDesire > 0 ) 
	then
	--print("useRC")
		npcBot:Action_UseAbilityOnLocation( abilityRC, castRCLocation );
		return;
	end
	
	if ( castDCDesire > 0 ) 
	then
	--print("useDC")
		npcBot:Action_UseAbilityOnEntity( abilityDC, castDCTarget );
		return;
	end
	
	if ( castOCDesire > 0 ) 
	then
	--print("useOC")
		npcBot:Action_UseAbility( abilityOC );
		return;
	end
	
	if ( castSPDesire > 0 ) 
	then
		-- print("useSP")
		npcBot:Action_UseAbility( abilitySP );
		return;
	end
	
	if ( castSPIDesire > 0 ) 
	then
	-- print("useSPI")
		spiritState = 0;
		npcBot:Action_UseAbility( abilitySPI );
		return;
	end
	
	if ( castSPODesire > 0 ) 
	then
	-- print("useSPO")
		spiritState = 1
		npcBot:Action_UseAbility( abilitySPO );
		return;
	end
	--[[if moveDesire > 0 
	then
		npcBot:Action_MoveToLocation( moveLocation );
		return;
	end]]--
	
	
end


function CanCastDeathCoilOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function isDisabled(npcTarget)
	if npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) or npcTarget:IsSilenced( )  then
		return true;
	end
	return false;
end

function ConsiderDeathCoil()

	-- Make sure it's castable
	if ( not abilityDC:IsFullyCastable() or abilityDC:IsHidden() or npcBot:HasModifier("modifier_wisp_tether") ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if castRCDesire > 0 then
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityDC:GetCastRange();
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	
	-- If we're seriously retreating, see if we can suicide
	if mutil.IsRetreating(npcBot) and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 
	then
		local numPlayer =  GetTeamPlayers(GetTeam());
		local maxDist = 0;
		local target = nil;
		for i = 1, #numPlayer
		do
			local dist = GetUnitToUnitDistance(GetTeamMember(i), npcBot);
			if dist > maxDist and dist < nCastRange and GetTeamMember(i):IsAlive() then
				maxDist = dist;
				target = GetTeamMember(i);
			end
		end
		if target ~= nil then
			return BOT_ACTION_DESIRE_MODERATE, target;
		end
		local tableNearbyCreeps = npcBot:GetNearbyLaneCreeps( 1000, false );
		for _,creep in pairs(tableNearbyCreeps)
		do
			local dist = GetUnitToUnitDistance(creep, npcBot);
			if dist > maxDist and dist < nCastRange then
				maxDist = dist;
				target = creep;
			end
		end
		if target ~= nil then
			return BOT_ACTION_DESIRE_MODERATE, target;
		end
	end

	-- If we're in a teamfight, use it on the protect ally
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local lowHpAlly = nil;
		local nLowestHealth = 1000;

		local tableNearbyAllies = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE  );
		for _,npcAlly in pairs( tableNearbyAllies )
		do
			if ( CanCastDeathCoilOnTarget( npcAlly ) )
			then
				local nAllyHP = npcAlly:GetHealth();
				if ( ( nAllyHP < nLowestHealth and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.5 ) or isDisabled(npcAlly) )
				then
					nLowestHealth = nAllyHP;
					lowHpAlly = npcAlly;
				end
			end
		end
		if ( lowHpAlly ~= nil )
		then
			return BOT_ACTION_DESIRE_MODERATE, lowHpAlly;
		end
	end

	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, npcBot ) < 1000 ) 
		then
			local numPlayer =  GetTeamPlayers(GetTeam());
			local minDist = 10000;
			local target = nil;
			for i = 1, #numPlayer
			do
				local dist = GetUnitToUnitDistance(GetTeamMember(i), npcTarget);
				if dist < minDist and dist < nCastRange and GetTeamMember(i):IsAlive() then
					minDist = dist;
					target = GetTeamMember(i);
				end
			end
			if target ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, target;
			end
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_ROAM or
	   npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
	   npcBot:GetActiveMode() == BOT_MODE_GANK 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, npcBot ) > 5000 ) 
		then
			local tableNearbyAllies = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE  );
			if tableNearbyAllies ~= nil and #tableNearbyAllies >= 1 and abilityRC:IsFullyCastable() then
				return BOT_ACTION_DESIRE_MODERATE, tableNearbyAllies[1];
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderSpirits()

	-- Make sure it's castable
	if ( not abilitySP:IsFullyCastable() or abilitySP:IsHidden() == true ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	local nMaxRange = abilitySP:GetSpecialValueInt("max_range");
	--[[if npcBot:DistanceFromFountain() > 1000 then
		return BOT_ACTION_DESIRE_MODERATE
	end]]--
	
	if  mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, npcBot ) < nMaxRange ) 
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderSpiritsIn()

	-- Make sure it's castable
	if ( spiritState == 0 or not abilitySPI:IsFullyCastable() or abilitySPI:IsHidden() or not npcBot:HasModifier("modifier_wisp_spirits") ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nMinRange = abilitySP:GetSpecialValueInt("min_range");
	local nMaxRange = abilitySP:GetSpecialValueInt("max_range");
	local nRadius = abilitySP:GetSpecialValueInt("radius");
	
	if  mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, npcBot ) < nMaxRange /2 )
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderSpiritsOut()
	
	-- Make sure it's castable
	if ( spiritState == 1 or not abilitySPO:IsFullyCastable() or abilitySPO:IsHidden() or not npcBot:HasModifier("modifier_wisp_spirits") ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	local nMinRange = abilitySP:GetSpecialValueInt("min_range");
	local nMaxRange = abilitySP:GetSpecialValueInt("max_range");
	local nRadius = abilitySP:GetSpecialValueInt("radius");
	
	if  mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, npcBot ) >= nMaxRange/2  ) 
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderOverCharge()

	-- Make sure it's castable
	if ( not abilityOC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local tetheredAlly = nil; 
	
	local NearbyAttackingAllies = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	for _,ally in pairs(NearbyAttackingAllies)
	do
		if ally:HasModifier('modifier_wisp_tether') then
			tetheredAlly = ally
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 and npcBot:WasRecentlyDamagedByAnyHero(2.0) then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	if npcBot:GetActiveMode() == BOT_MODE_ATTACK and tetheredAlly ~= nil and npcBot:HasModifier('modifier_wisp_tether') then
		local npcTarget = npcBot:GetTarget();
		local allyAttackRange = tetheredAlly:GetAttackRange();
		local nAttackRange = npcBot:GetAttackRange();
		if npcTarget ~= nil and npcTarget:IsHero() and 
			( GetUnitToUnitDistance(npcTarget ,tetheredAlly) <= allyAttackRange or  GetUnitToUnitDistance(npcTarget ,npcBot) <= nAttackRange )
		then
			return BOT_ACTION_DESIRE_MODERATE
		end	
	end

	-- if npcBot:GetActiveMode() == BOT_MODE_ATTACK and tetheredAlly ~= nil then
	-- 	local npcTarget = npcBot:GetTarget();
	-- 	local allyAttackRange = tetheredAlly:GetAttackRange();
	-- 	local nAttackRange = npcBot:GetAttackRange();
	-- 	if npcTarget ~= nil and npcTarget:IsHero() and 
	-- 		( GetUnitToUnitDistance(npcTarget ,tetheredAlly) <= allyAttackRange or  GetUnitToUnitDistance(npcTarget ,npcBot) <= nAttackRange )
	-- 	then
	-- 		if  npcBot:HasModifier('modifier_wisp_tether') and npcBot:GetHealth()/npcBot:GetMaxHealth() > .3 and npcBot:GetMana()/npcBot:GetMaxMana() > .15 then
	-- 			if not abilityOC:GetToggleState() then
	-- 				return BOT_ACTION_DESIRE_MODERATE
	-- 			end
	-- 		else
	-- 			if abilityOC:GetToggleState() then
	-- 				return BOT_ACTION_DESIRE_MODERATE
	-- 			end
	-- 		end
	-- 	else
	-- 		if abilityOC:GetToggleState() then
	-- 			return BOT_ACTION_DESIRE_MODERATE
	-- 		end
	-- 	end	
	-- else
	-- 	if abilityOC:GetToggleState() then
	-- 		return BOT_ACTION_DESIRE_MODERATE
	-- 	end
	-- end
	
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderRelocate()

	-- Make sure it's castable
	if ( not abilityRC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 and npcBot:WasRecentlyDamagedByAnyHero(1.0) then
			local location = mutil.GetTeamFountain();
			return BOT_ACTION_DESIRE_MODERATE, location;
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local lowHpAlly = nil;
		local nLowestHealth = 1000;

		local tableNearbyAllies = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE  );
		for _,npcAlly in pairs( tableNearbyAllies )
		do
			if ( CanCastDeathCoilOnTarget( npcAlly ) )
			then
				local nAllyHP = npcAlly:GetHealth();
				if npcAlly:HasModifier('modifier_wisp_tether') and ( ( nAllyHP < nLowestHealth and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.35 ) or isDisabled(npcAlly) )
				then
					nLowestHealth = nAllyHP;
					lowHpAlly = npcAlly;
				end
			end
		end
		if ( lowHpAlly ~= nil and abilityDC:IsFullyCastable() )
		then
			local location = mutil.GetTeamFountain();
			return BOT_ACTION_DESIRE_MODERATE, location;
		end
	end

	if  mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, npcBot ) > 3000  ) 
		then
			local tableNearbyAllies = npcTarget:GetNearbyHeroes( 1300, true, BOT_MODE_NONE  );
			if tableNearbyAllies ~= nil and #tableNearbyAllies >= 2 and abilityDC:IsFullyCastable() then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0; 
end

function ConsiderMoving()

	if DotaTime() < 0 and npcBot:DistanceFromFountain() < 1000 then
		return BOT_ACTION_DESIRE_HIGH, GetTower( GetTeam(), TOWER_MID_3 ):GetLocation() + RandomVector(200);
	end
	
	return BOT_ACTION_DESIRE_NONE, 0; 
end