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

local ClosingDesire = 0;
local castSCDesire = 0;
local castTCDesire = 0;
local castCHDesire = 0;
local castCH2Desire = 0;
local castCHRDesire = 0;
local castCHR2Desire = 0;

local abilitySC = nil;
local abilityTC = nil;
local abilityCH = nil;
local abilityCH2 = nil;
local abilityCHR = nil;
local abilityCHR2 = nil;

local ultLoc = 0;
local ultLoc2 = 0;
local npcBot = nil;
local ultTime1 = 0;
local ultETA1 = 0;
local ultTime2 = 0;
local ultETA2 = 0;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	-- Check if we're already using an ability
	
	if mutil.CanNotUseAbility(npcBot) then return end

	if abilitySC == nil then abilitySC = npcBot:GetAbilityByName( "shredder_whirling_death" ) end
	if abilityTC == nil then abilityTC = npcBot:GetAbilityByName( "shredder_timber_chain" ) end
	if abilityCH == nil then abilityCH = npcBot:GetAbilityByName( "shredder_chakram" ) end
	if abilityCH2 == nil then abilityCH2 = npcBot:GetAbilityByName( "shredder_chakram_2" ) end
	if abilityCHR == nil then abilityCHR = npcBot:GetAbilityByName( "shredder_return_chakram" ) end
	if abilityCHR2 == nil then abilityCHR2 = npcBot:GetAbilityByName( "shredder_return_chakram_2" ) end

	-- Consider using each ability
	castSCDesire = ConsiderSlithereenCrush();
	castTCDesire, castTree, castType = ConsiderTimberChain();
	castCHDesire, castCHLocation, eta = ConsiderChakram();
	castCH2Desire, castCH2Location, eta2 = ConsiderChakram2();
	castCHRDesire = ConsiderChakramReturn();
	castCHR2Desire = ConsiderChakramReturn2();
	ClosingDesire, Target = ConsiderClosing();
	
	if ( castCHRDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityCHR );
		ultLoc = Vector(-6376, 6419, 0); 
		return;
	end
	
	if ( castCHR2Desire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityCHR2 );
		ultLoc2 = Vector(-6376, 6419, 0); 
		return;
	end
	
	if ( castCHDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityCH, castCHLocation );
		ultLoc = castCHLocation; 
		ultTime1 = DotaTime();
		ultETA1 = eta + 0.5;
		return;
	end
	
	if ( castCH2Desire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityCH2, castCH2Location );
		ultLoc2 = castCH2Location; 
		ultTime2 = DotaTime();
		ultETA2 = eta2 + 0.5;
		return;
	end
	
	if ( castTCDesire > 0 ) 
	then
		--print("Chain")
		if castType == "tree" then
			npcBot:Action_UseAbilityOnLocation( abilityTC, GetTreeLocation(castTree) );
		else
			npcBot:Action_UseAbilityOnLocation( abilityTC, castTree );
		end	
		return;
	end
	
	if ( castSCDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilitySC );
		return;
	end
	
	if ClosingDesire > 0 then
		npcBot:Action_MoveToLocation(Target);
		return
	end
	
end

function StillTraveling(cType)
	local proj = GetLinearProjectiles();
	for _,p in pairs(proj)
	do
		if p ~= nil and (( cType == 1 and p.ability:GetName() == "shredder_chakram" ) or (  cType == 2 and p.ability:GetName() == "shredder_chakram_2" ) ) then
			return true; 
		end
	end
	return false;
end

function GetBestTree(npcBot, enemy, nCastRange, hitRadios)
   
	--find a tree behind enemy
	local bestTree=nil;
	local mindis=10000;

	local trees=npcBot:GetNearbyTrees(nCastRange);
	
	for _,tree in pairs(trees) do
		local x=GetTreeLocation(tree);
		local y=npcBot:GetLocation();
		local z=enemy:GetLocation();
		
		if x~=y then
			local a=1;
			local b=1;
			local c=0;
		
			if x.x-y.x ==0 then
				b=0;
				c=-x.x;
			else
				a=-(x.y-y.y)/(x.x-y.x);
				c=-(x.y + x.x*a);
			end
		
			local d = math.abs((a*z.x+b*z.y+c)/math.sqrt(a*a+b*b));
			if d<=hitRadios and mindis>GetUnitToLocationDistance(enemy,x) and (GetUnitToLocationDistance(enemy,x)<=GetUnitToLocationDistance(npcBot,x)) then
				bestTree=tree;
				mindis=GetUnitToLocationDistance(enemy,x);
			end
		end
	end
	
	return bestTree;

end

function GetBestRetreatTree(npcBot, nCastRange)
	local trees=npcBot:GetNearbyTrees(nCastRange);
	
	local dest=utils.VectorTowards(npcBot:GetLocation(),utils.Fountain(GetTeam()),1000);
	
	local BestTree=nil;
	local maxdis=0;
	
	for _,tree in pairs(trees) do
		local loc=GetTreeLocation(tree);
		
		if (not utils.AreTreesBetween(loc,100)) and 
			GetUnitToLocationDistance(npcBot,loc)>maxdis and 
			GetUnitToLocationDistance(npcBot,loc)<nCastRange and 
			utils.GetDistance(loc,dest)<880 
		then
			maxdis=GetUnitToLocationDistance(npcBot,loc);
			BestTree=loc;
		end
	end
	
	if BestTree~=nil and maxdis>250 then
		return BestTree;
	end
	
	return nil;
end

function GetUltLoc(npcBot, enemy, nManaCost, nCastRange, s)

	local v=enemy:GetVelocity();
	local sv=utils.GetDistance(Vector(0,0),v);
	if sv>800 then
		v=(v / sv) * enemy:GetCurrentMovementSpeed();
	end
	
	local x=npcBot:GetLocation();
	local y=enemy:GetLocation();
	
	local a=v.x*v.x + v.y*v.y - s*s;
	local b=-2*(v.x*(x.x-y.x) + v.y*(x.y-y.y));
	local c= (x.x-y.x)*(x.x-y.x) + (x.y-y.y)*(x.y-y.y);
	
	local t=math.max((-b+math.sqrt(b*b-4*a*c))/(2*a) , (-b-math.sqrt(b*b-4*a*c))/(2*a));
	
	local dest = (t+0.35)*v + y;

	if GetUnitToLocationDistance(npcBot,dest)>nCastRange or npcBot:GetMana()<100+nManaCost then
		return nil;
	end
	
	if enemy:GetMovementDirectionStability()<0.4 or ((not utils.IsFacingLocation(enemy,utils.Fountain(GetOpposingTeam()),60)) ) then
		dest=utils.VectorTowards(y,utils.Fountain(GetOpposingTeam()),180);
	end

	if mutil.IsDisabled(true, enemy) then
		dest=enemy:GetLocation();
	end
	
	return dest;
	
end

function ConsiderClosing()

	-- Make sure it's castable
	if ( not npcBot:HasModifier("modifier_shredder_chakram_disarm") ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if  mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 1000) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderSlithereenCrush()

	-- Make sure it's castable
	if ( not abilitySC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRadius = abilitySC:GetSpecialValueInt( "whirling_radius" );
	local nCastRange = 0;
	local nDamage = abilitySC:GetSpecialValueInt("whirling_damage");

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
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
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 ) then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	-- If we're farming and can kill 3+ creeps with LSA
	if mutil.IsPushing(npcBot)
	then
		local NearbyCreeps = npcBot:GetNearbyLaneCreeps(nRadius, true);
		if NearbyCreeps ~= nil and #NearbyCreeps >= 3 and npcBot:GetMana()/npcBot:GetMaxMana() > 0.65 then 
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();

		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end


	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderTimberChain()

	-- Make sure it's castable
	if ( not abilityTC:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	-- Get some of its values
	local nRadius = abilityTC:GetSpecialValueInt( "chain_radius" );
	local nSpeed = abilityTC:GetSpecialValueInt( "speed" );
	local nCastRange = mutil.GetProperCastRange(false, npcBot, abilityTC:GetCastRange());
	local nDamage = abilityTC:GetSpecialValueInt("damage");

	if mutil.IsStuck(npcBot)
	then
		return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsTowardsLocation( GetAncient(GetTeam()):GetLocation(), nCastRange ), "loc";
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) and npcBot:DistanceFromFountain() > 1000
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 then
			local BRTree = GetBestRetreatTree(npcBot, nCastRange);
			if BRTree ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, BRTree, "loc";
			end
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange) and
			not utils.AreTreesBetween( npcTarget:GetLocation(),nRadius ) ) 
		then
			
			local BTree = GetBestTree(npcBot, npcTarget, nCastRange, nRadius);
			if BTree ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, BTree, "tree";
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderChakram()

	-- Make sure it's castable
	if ( not abilityCH:IsFullyCastable() or abilityCH:IsHidden() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0, 0;
	end


	-- Get some of its values
	local nRadius = abilityCH:GetSpecialValueFloat( "radius" );
	local nSpeed = abilityCH:GetSpecialValueFloat( "speed" );
	local nCastRange = mutil.GetProperCastRange(false, npcBot, abilityCH:GetCastRange());
	local nManaCost = abilityCH:GetManaCost( );
	local nDamage = 2*abilityCH:GetSpecialValueInt("pass_damage");

	--------------------------------------
	-- Mode based usage
	-------------------------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				local loc = npcEnemy:GetLocation();
				local eta = GetUnitToLocationDistance(npcBot, loc) / nSpeed;
				return BOT_ACTION_DESIRE_MODERATE, loc, eta;
			end
		end
	end
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 3 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.65 ) 
		then
			local loc = locationAoE.targetloc;
			local eta = GetUnitToLocationDistance(npcBot, loc) / nSpeed;
			return BOT_ACTION_DESIRE_LOW, loc, eta;
		end
	end

	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange-200) 
		then
			local Loc = GetUltLoc(npcBot, npcTarget, nManaCost, nCastRange, nSpeed)
			if Loc ~= nil then
				local eta = GetUnitToLocationDistance(npcBot, Loc) / nSpeed;
				return BOT_ACTION_DESIRE_MODERATE, Loc, eta;
			end
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderChakram2()

	-- Make sure it's castable
	if ( not npcBot:HasScepter() or not abilityCH2:IsFullyCastable() or abilityCH2:IsHidden() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nRadius = abilityCH:GetSpecialValueFloat( "radius" );
	local nSpeed = abilityCH:GetSpecialValueFloat( "speed" );
	local nCastRange = mutil.GetProperCastRange(false, npcBot, abilityCH:GetCastRange());
	local nManaCost = abilityCH:GetManaCost( );
	local nDamage = 2*abilityCH:GetSpecialValueInt("pass_damage");

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				local loc = npcEnemy:GetLocation();
				local eta = GetUnitToLocationDistance(npcBot, loc) / nSpeed;
				return BOT_ACTION_DESIRE_MODERATE, loc, eta;
			end
		end
	end
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 3 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.65 ) 
		then
			local loc = locationAoE.targetloc
			local eta = GetUnitToLocationDistance(npcBot, loc) / nSpeed;
			return BOT_ACTION_DESIRE_LOW, loc, eta;
		end
	end

	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange-200) 
		then
			local Loc = GetUltLoc(npcBot, npcTarget, nManaCost, nCastRange, nSpeed)
			if Loc ~= nil then
				local eta = GetUnitToLocationDistance(npcBot, Loc) / nSpeed;
				return BOT_ACTION_DESIRE_MODERATE, Loc, eta;
			end
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderChakramReturn()

	-- Make sure it's castable
	if ( ultLoc == 0 or not abilityCHR:IsFullyCastable() or abilityCHR:IsHidden() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if DotaTime() < ultTime1 + ultETA1 or StillTraveling(1) then 
		return BOT_ACTION_DESIRE_NONE;
	end	
	
	local nRadius = abilityCH:GetSpecialValueFloat( "radius" );
	local nDamage = abilityCH:GetSpecialValueInt("pass_damage");
	local nManaCost = abilityCH:GetManaCost( );
	
	if npcBot:GetMana() < 100 or GetUnitToLocationDistance(npcBot, ultLoc) > 1600 then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	if  mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) 
	then
		local nUnits = 0;
		local nLowHPUnits = 0;
		local NearbyUnits = npcBot:GetNearbyLaneCreeps(1300, true);
		for _,c in pairs(NearbyUnits)
		do 
			if GetUnitToLocationDistance(c, ultLoc) < nRadius  then
				nUnits = nUnits + 1;
			end
			if GetUnitToLocationDistance(c, ultLoc) < nRadius and c:GetHealth() <= nDamage then
				nLowHPUnits = nLowHPUnits + 1;
			end
		end
		if nUnits == 0 or nLowHPUnits >= 1  then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if  npcBot:GetActiveMode() == BOT_MODE_RETREAT or mutil.IsGoingOnSomeone(npcBot) 
	then
		local nUnits = 0;
		local nLowHPUnits = 0;
		local NearbyUnits = npcBot:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
		for _,c in pairs(NearbyUnits)
		do 
			if GetUnitToLocationDistance(c, ultLoc) < nRadius  then
				nUnits = nUnits + 1;
			end
			if GetUnitToLocationDistance(c, ultLoc) < nRadius and c:GetHealth() <= nDamage / 2 then
				nLowHPUnits = nLowHPUnits + 1;
			end
		end
		if nUnits == 0 or nLowHPUnits >= 1 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	local enemies = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local creeps = npcBot:GetNearbyLaneCreeps(1600, true)
	if #enemies == 0 and #creeps == 0 then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderChakramReturn2()

	-- Make sure it's castable
	if ( not npcBot:HasScepter() or ultLoc2 == 0 or not abilityCHR2:IsFullyCastable() or abilityCHR2:IsHidden() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if DotaTime() < ultTime2 + ultETA2 or StillTraveling(2) then 
		return BOT_ACTION_DESIRE_NONE;
	end	
	
	local nRadius = abilityCH:GetSpecialValueFloat( "radius" );
	local nDamage = abilityCH:GetSpecialValueInt("pass_damage");
	local nManaCost = abilityCH:GetManaCost( );
	
	if npcBot:GetMana() < 100 or GetUnitToLocationDistance(npcBot, ultLoc2) > 1600 then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) 
	then
		local nUnits = 0;
		local nLowHPUnits = 0;
		local NearbyUnits = npcBot:GetNearbyLaneCreeps(1000, true);
		for _,c in pairs(NearbyUnits)
		do 
			if GetUnitToLocationDistance(c, ultLoc2) < nRadius  then
				nUnits = nUnits + 1;
			end
			if GetUnitToLocationDistance(c, ultLoc2) < nRadius and c:GetHealth() <= nDamage then
				nLowHPUnits = nLowHPUnits + 1;
			end
		end
		--print("Push"..nUnits)
		if nUnits == 0 or nLowHPUnits >= 1  then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_RETREAT or mutil.IsGoingOnSomeone(npcBot) 
	then
		local nUnits = 0;
		local nLowHPUnits = 0;
		local NearbyUnits = npcBot:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
		for _,c in pairs(NearbyUnits)
		do 
			if GetUnitToLocationDistance(c, ultLoc2) < nRadius  then
				nUnits = nUnits + 1;
			end
			if GetUnitToLocationDistance(c, ultLoc2) < nRadius and c:GetHealth() <= nDamage / 2 then
				nLowHPUnits = nLowHPUnits + 1;
			end
		end
		--print("Attck"..nUnits)
		if nUnits == 0 or nLowHPUnits >= 1 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	local enemies = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local creeps = npcBot:GetNearbyLaneCreeps(1600, true)
	if #enemies == 0 and #creeps == 0 then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	return BOT_ACTION_DESIRE_NONE;
end