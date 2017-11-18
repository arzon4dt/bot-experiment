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

local npcBot = GetBot();

local abilityQ = nil;
local abilityW = nil;
local abilityE = nil;
local abilityD = nil;
local abilityF = nil;
local abilityR = nil;
local gripAllies = nil;

local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castDDesire = 0;
local castFDesire = 0;
local castRDesire = 0;

local nStone = 0;

local remnantLoc = {};
local remnantCastTime = -100;
local remnantCastGap  = 0.1;
local stoneCast = -100;
local stoneCastGap = 1.0;

function AbilityUsageThink()
	
	nStone = npcBot:GetModifierStackCount(npcBot:GetModifierByName('modifier_earth_spirit_stone_caller_charge_counter'));
	
	if npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced() or npcBot:NumQueuedActions() > 0 then return end
	
	if abilityQ == nil then abilityQ = npcBot:GetAbilityByName( "earth_spirit_boulder_smash" ) end
	if abilityW == nil then abilityW = npcBot:GetAbilityByName( "earth_spirit_rolling_boulder" ) end
	if abilityE == nil then abilityE = npcBot:GetAbilityByName( "earth_spirit_geomagnetic_grip" ) end
	if abilityD == nil then abilityD = npcBot:GetAbilityByName( "earth_spirit_stone_caller" ) end
	if abilityF == nil then abilityF = npcBot:GetAbilityByName( "earth_spirit_petrify" ) end
	if abilityR == nil then abilityR = npcBot:GetAbilityByName( "earth_spirit_magnetize" ) end
	if gripAllies == nil then gripAllies = npcBot:GetAbilityByName( "special_bonus_unique_earth_spirit_2" ) end

	castQDesire, castQLoc, castQStone, QStoneNear = ConsiderQ();
	castWDesire, castWLoc, castWStone, WStoneNear = ConsiderW();
    castEDesire, castELoc, castEStone, EStoneNear = ConsiderE();
	castDDesire, castDLoc             = ConsiderD();
	castFDesire, castFTarget          = ConsiderF();
	castRDesire                       = ConsiderR();

	
	if ( castRDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityR );
		return;
	end
	
	
	if ( castFDesire > 0 ) 
	then
		--npcBot:Action_UseAbilityOnEntity( abilityF, castFTarget );
		npcBot:ActionQueue_UseAbilityOnEntity(abilityF, castFTarget);
		npcBot:ActionQueue_UseAbilityOnLocation(abilityQ, npcBot:GetLocation()+RandomVector(800));
		return;
	end

	if ( castQDesire > 0 ) 
	then
		if castQStone then
			npcBot:Action_ClearActions(false);
			npcBot:ActionQueue_UseAbilityOnLocation(abilityD, npcBot:GetLocation());
			npcBot:ActionQueue_UseAbilityOnLocation(abilityQ, castQLoc);
			return;
		else
			if QStoneNear then
				npcBot:Action_UseAbilityOnLocation( abilityQ, castQLoc );
				return;
			else
				npcBot:Action_UseAbilityOnEntity( abilityQ, castQLoc );
				return;
			end
		end
	end
	
	if ( castWDesire > 0 ) 
	then
		if castWStone then
			npcBot:Action_ClearActions(false);
			npcBot:ActionQueue_UseAbilityOnLocation(abilityW, castWLoc);
			npcBot:ActionQueue_UseAbilityOnLocation(abilityD, npcBot:GetXUnitsTowardsLocation(castWLoc, 300));
			return;
		else
			npcBot:Action_UseAbilityOnLocation( abilityW, castWLoc );
			return;
		end
	end
	
	if ( castEDesire > 0 ) 
	then
		if castEStone then
			npcBot:Action_ClearActions(false);
			npcBot:ActionQueue_UseAbilityOnLocation(abilityD, castELoc);
			npcBot:ActionQueue_UseAbilityOnLocation(abilityE, castELoc);
			return;
		else
			npcBot:Action_UseAbilityOnLocation( abilityE, castELoc );
			return;
		end
	end
	
	if ( castDDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityD, castDLoc );
		npcBot:ActionImmediate_Chat( "RESET BOYS", true );
		stoneCast = DotaTime();
		return;
	end
	
end

function IsStoneNearby(location, radius)
	local units = GetUnitList(UNIT_LIST_ALLIED_OTHER);
	for _,u in pairs(units) do
		if u ~= nil and u:GetUnitName() == "npc_dota_earth_spirit_stone" and GetUnitToLocationDistance(u, location) < radius then
			return true;
		end
	end
	return false;
end 

function IsStoneInPath(location, dist)
	if npcBot:IsFacingLocation(location, 5) then
		local units = GetUnitList(UNIT_LIST_ALLIED_OTHER);
		for _,u in pairs(units) do
			if u ~= nil and u:GetUnitName() == "npc_dota_earth_spirit_stone" 
			   and npcBot:IsFacingLocation(u:GetLocation(), 5) and GetUnitToUnitDistance(u, npcBot) < dist 
			then
				return true;
			end
		end
	end
	return false;
end

function CanChainMag(target, radius)
	local enemies = target:GetNearbyHeroes(radius, false, BOT_MODE_NONE);
	for _,enemy in pairs(enemies)
	do
		if not enemy:HasModifier('modifier_earth_spirit_magnetize') then
			return true
		end	
	end
	return false;
end

function ConsiderQ()

	-- Make sure it's castable
	if ( not abilityQ:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0, false, false;
	end

	-- Get some of its values
	local nRadius     = abilityQ:GetSpecialValueInt('radius');
	local nSearchRad  = abilityQ:GetSpecialValueInt('rock_search_aoe');
	local nUnitCR     = 150;
	local nStoneCR    = abilityQ:GetSpecialValueInt('rock_distance');
	local nCastPoint  = abilityQ:GetCastPoint( );
	local nManaCost   = abilityQ:GetManaCost( );
	local nSpeed      = abilityQ:GetSpecialValueInt('speed');
	local nDamage     = abilityQ:GetSpecialValueInt('rock_damage');

	if nStoneCR > 1600 then nStoneCR = 1300 end
	
	local stoneNearby = IsStoneNearby(npcBot:GetLocation(), nSearchRad);
	
	--if we can kill any enemies
	if stoneNearby then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nStoneCR, true, BOT_MODE_NONE );
		local target = mutil.GetCanBeKilledUnit(tableNearbyEnemyHeroes, nDamage, DAMAGE_TYPE_MAGICAL, false)
		if target ~= nil then
			local loc = mutil.GetCorrectLoc(target, GetUnitToUnitDistance(npcBot, target)/nSpeed)
			return BOT_ACTION_DESIRE_HIGH, loc, false, true; 
		end
	elseif nStone >= 1 then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nStoneCR, true, BOT_MODE_NONE );
		local target = mutil.GetCanBeKilledUnit(tableNearbyEnemyHeroes, nDamage, DAMAGE_TYPE_MAGICAL, false)
		if target ~= nil then
			local loc = mutil.GetCorrectLoc(target, GetUnitToUnitDistance(npcBot, target)/nSpeed)
			return BOT_ACTION_DESIRE_HIGH, loc, true, false; 
		end
	elseif nStone < 1 then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nUnitCR+200, true, BOT_MODE_NONE );
		local target = mutil.GetCanBeKilledUnit(tableNearbyEnemyHeroes, nDamage, DAMAGE_TYPE_MAGICAL, false)
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target, false, false; 
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) and npcBot:WasRecentlyDamagedByAnyHero( 1.0 )
	then
		if stoneNearby then
			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nStone, true, BOT_MODE_NONE );
			local target = mutil.GetClosestUnit(tableNearbyEnemyHeroes)
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation(), false, true; 
			end
		elseif nStone >= 1 then
			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nStone, true, BOT_MODE_NONE );
			local target = mutil.GetClosestUnit(tableNearbyEnemyHeroes)
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation(), true, false; 
			end
		elseif nStone < 1 then
			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nUnitCR+200, true, BOT_MODE_NONE );
			local target = mutil.GetClosestUnit(tableNearbyEnemyHeroes)
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, target, false, false; 
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nStoneCR, nRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			if stoneNearby then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, false, true;
			elseif nStone >= 1 then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, true, false;
			end
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot) 
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nStoneCR + 200) 
		then
			local loc = mutil.GetCorrectLoc(npcTarget, GetUnitToUnitDistance(npcBot, target)/nSpeed)
			if stoneNearby then
				return BOT_ACTION_DESIRE_HIGH, loc, false, true;
			elseif nStone >= 1 then
				return BOT_ACTION_DESIRE_HIGH, loc, true, false;
			end
		end
	end
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nStoneCR, 2.0);
	
	if skThere and nStone >= 1 then
		return BOT_ACTION_DESIRE_MODERATE, skLoc, true, false;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0, false, false;

end

function ConsiderW()

	-- Make sure it's castable
	if ( not abilityW:IsFullyCastable() or npcBot:IsRooted() ) then 
		return BOT_ACTION_DESIRE_NONE, 0, false;
	end

	-- Get some of its values
	local nRadius     = abilityW:GetSpecialValueInt('radius');
	local nUnitCR     = abilityW:GetSpecialValueInt('distance');
	local nStoneCR    = abilityW:GetSpecialValueInt('rock_distance');
	local nCastPoint  = abilityW:GetCastPoint( );
	local nDelay      = abilityW:GetSpecialValueFloat('delay');
	local nManaCost   = abilityW:GetManaCost( );
	local nSpeed      = abilityW:GetSpecialValueInt('speed');
	local nRSpeed     = abilityW:GetSpecialValueInt('rock_speed');
	local nDamage     = abilityW:GetSpecialValueInt('damage');
	
	if nStoneCR > 1600 then nStoneCR = 1300 end
	
	if mutil.IsStuck(npcBot)
	then
		local loc = mutil.GetEscapeLoc();
		return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsTowardsLocation( loc, nStoneCR );
	end
	
	--if we can kill any enemies
	if nStone >= 1 then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nStoneCR, true, BOT_MODE_NONE );
		local target = mutil.GetCanBeKilledUnit(tableNearbyEnemyHeroes, nDamage, DAMAGE_TYPE_MAGICAL, false)
		if target ~= nil then
			local loc = mutil.GetCorrectLoc(target, (GetUnitToUnitDistance(npcBot, target)/nRSpeed)+nDelay)
			if IsStoneInPath(loc, (nUnitCR/2)+200) then
				return BOT_ACTION_DESIRE_HIGH, loc, false; 
			else
				return BOT_ACTION_DESIRE_HIGH, loc, true; 
			end
		end
	elseif nStone < 1 then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nUnitCR-200, true, BOT_MODE_NONE );
		local target = mutil.GetCanBeKilledUnit(tableNearbyEnemyHeroes, nDamage, DAMAGE_TYPE_MAGICAL, false)
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target, false; 
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) and npcBot:WasRecentlyDamagedByAnyHero( 1.0 )
	then
		local location = mutil.GetEscapeLoc();
		local loc = npcBot:GetXUnitsTowardsLocation( location, nUnitCR );
		if IsStoneInPath(loc, (nUnitCR/2)+200) then
			return BOT_ACTION_DESIRE_MODERATE, loc, false;
		elseif nStone >= 1 then
			return BOT_ACTION_DESIRE_MODERATE, loc, true;
		elseif nStone < 1 then
			return BOT_ACTION_DESIRE_MODERATE, loc, false;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot) 
	then
		local npcTarget = npcBot:GetTarget();
		if nStone >= 1 and mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nStoneCR + 200) 
		then
			local targetAlly  = npcTarget:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
			local targetEnemy = npcTarget:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
			if targetEnemy ~= nil and targetAlly ~= nil and #targetEnemy >= #targetAlly then
				local loc = mutil.GetCorrectLoc(npcTarget, GetUnitToUnitDistance(npcBot, target)/nRSpeed)
				if IsStoneInPath(loc, (nUnitCR/2)+200) then
					return BOT_ACTION_DESIRE_HIGH, loc, false;
				else
					return BOT_ACTION_DESIRE_HIGH, loc, true;
				end
			end	
		elseif nStone < 1 and mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nUnitCR / 2)  then
			local loc = mutil.GetCorrectLoc(npcTarget, GetUnitToUnitDistance(npcBot, target)/nSpeed)
			return BOT_ACTION_DESIRE_HIGH, loc, false;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0, false;

end

function ConsiderE()

	-- Make sure it's castable
	if ( not abilityE:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0, false, false;
	end

	-- Get some of its values
	local nRadius     = abilityE:GetSpecialValueInt('radius');
	local nSearchRad  = 175;
	local nCastRange  = abilityE:GetCastRange();
	local nCastPoint  = abilityE:GetCastPoint( );
	local nManaCost   = abilityE:GetManaCost( );
	local nDamage     = abilityE:GetSpecialValueInt('rock_damage');
	
	if gripAllies ~= nil and gripAllies:IsTrained() then
		local tableNearbyAllies = npcBot:GetNearbyHeroes( nCastRange+200, false, BOT_MODE_NONE );
		for _,ally in pairs(tableNearbyAllies) 
		do
			if ally:GetActiveMode() == BOT_MODE_RETREAT and ally:WasRecentlyDamagedByAnyHero(2.0) then
				return BOT_ACTION_DESIRE_HIGH, ally:GetLocation(), false, true; 
			end
		end
	end	
	
	--if we can kill any enemies
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	local target = mutil.GetCanBeKilledUnit(tableNearbyEnemyHeroes, nDamage, DAMAGE_TYPE_MAGICAL, false)
	if target ~= nil then
		local loc = mutil.GetCorrectLoc(target, 2*nCastPoint)
		local stoneNearby = IsStoneNearby(loc, nSearchRad);
		if stoneNearby and ( nStone >= 1 or  nStone < 1 ) then
			return BOT_ACTION_DESIRE_HIGH, loc, false, true; 
		elseif nStone >= 1 then
			return BOT_ACTION_DESIRE_HIGH, loc, true, false; 
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			local stoneNearby = IsStoneNearby(locationAoE.targetloc, nSearchRad);
			if stoneNearby and ( nStone >= 1 or  nStone < 1 ) then
				return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc, false, true; 
			elseif nStone >= 1 then
				return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc, true, false; 
			end
		end
	end

	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot) 
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange - 200) 
		then
			local targetAlly  = npcTarget:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
			local targetEnemy = npcTarget:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
			if targetEnemy ~= nil and targetAlly ~= nil and #targetEnemy >= #targetAlly then
				local loc = mutil.GetCorrectLoc(npcTarget, 2*nCastPoint)
				local stoneNearby = IsStoneNearby(loc, nSearchRad);
				if stoneNearby and ( nStone >= 1 or  nStone < 1 ) then
					return BOT_ACTION_DESIRE_HIGH, loc, false, true; 
				elseif nStone >= 1 then
					return BOT_ACTION_DESIRE_HIGH, loc, true, false; 
				end
			end	
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0, false, false;

end

function ConsiderD()
	
	-- Make sure it's castable
	if ( not abilityD:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if DotaTime() < stoneCast + stoneCastGap then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange  = abilityD:GetCastRange( );
	local nRadius     = abilityR:GetSpecialValueInt('rock_search_radius');
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange - 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if npcEnemy:HasModifier('modifier_earth_spirit_magnetize') 
		then
			local duration = npcEnemy:GetModifierRemainingDuration(npcEnemy:GetModifierByName('modifier_earth_spirit_magnetize'));
			if duration < 1.0 or CanChainMag(npcEnemy, nRadius) then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderF()
	-- Make sure it's castable
	if ( not abilityF:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderR()

	-- Make sure it's castable
	if ( not abilityR:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nRadius    = abilityR:GetSpecialValueInt( "cast_radius" );
	local nCastPoint = abilityR:GetCastPoint( );
	local nManaCost  = abilityR:GetManaCost( );

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) and npcBot:IsMagicImmune()
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy)  ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 ) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius-100)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end
