if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local mutils = require(GetScriptDirectory() ..  "/MyUtility")
local abUtils = require(GetScriptDirectory() ..  "/AbilityItemUsageUtility")

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

local bot = GetBot();

local abilities = {};

local castCombo1Desire = 0;
local castCombo2Desire = 0;
local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castE2Desire = 0;
local castRDesire = 0;

local lastCheck = -90;

function AbilityUsageThink()
	
	if #abilities == 0 then abilities = mutils.InitiateAbilities(bot, {0,1,2,3,6}) end
	
	if mutils.CantUseAbility(bot) then return end
	
	castQDesire, targetQ 	= ConsiderQ();
	castWDesire, targetW 	= ConsiderW();
	castEDesire, targetE  	= ConsiderE();
	castE2Desire,targetE2   = ConsiderE2();
	castDDesire, targetD  	= ConsiderD();
	--castRDesire, targetR 	= ConsiderR();
	
	if castRDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[4], targetR);		
		return
	end
	
	if castQDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[1], targetQ);		
		return
	end
	
	if castWDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[2], targetW);		
		return
	end
	
	if castEDesire > 0 then
		bot:Action_UseAbilityOnTree( abilities[3], targetE );	
		return
	end
	
	if castE2Desire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[5], targetE2);		
		return
	end
	
	if castDDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[4], targetD);		
		return
	end
	
end

function ConsiderQ()
	if not mutils.CanBeCast(abilities[1]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[1]:GetCastRange());
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost  = abilities[1]:GetManaCost();
	local nRadius   = abilities[1]:GetSpecialValueInt( "radius" );
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
		end
	end
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and mutils.CanSpamSpell(bot, manaCost)
	then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 3 ) then
			local target = mutils.GetVulnerableUnitNearLoc(false, true, nCastRange, nRadius, locationAoE.targetloc, bot);
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
			end
		end
	end
	
	if mutils.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) then
			local target = mutils.GetVulnerableUnitNearLoc(true, true, nCastRange, nRadius, locationAoE.targetloc, bot);
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
			end
		end
	end
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and mutils.CanSpamSpell(bot, manaCost)
	then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 3 ) then
			local target = mutils.GetVulnerableUnitNearLoc(false, true, nCastRange, nRadius, locationAoE.targetloc, bot);
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
			end
		end
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange)
			and mutils.IsDisabled(true, target) == false
		then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function ConsiderW()
	if not mutils.CanBeCast(abilities[2]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[2]:GetCastRange());
	local nCastPoint = abilities[2]:GetCastPoint();
	local manaCost  = abilities[2]:GetManaCost();
	local nDamage  = abilities[1]:GetSpecialValueInt("avalanche_damage");
	local nDamage2  = abilities[2]:GetSpecialValueInt("toss_damage");
	local nRadius   = abilities[2]:GetSpecialValueInt( "grab_radius" );
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		if abilities[1]:IsFullyCastable() then 
			local enemies = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
			for i=1,#enemies do
				if mutils.IsValidTarget(enemies[i]) and mutils.CanCastOnNonMagicImmune(enemies[i]) and enemies[i]:GetHealth() < nDamage + nDamage2 then
					return BOT_ACTION_DESIRE_LOW, enemies[i];
				end
			end
		else
			local loc = mutils.GetEscapeLoc();
			local furthestTarget = mutils.GetFurthestUnitToLocationFrommAll(bot, nCastRange, loc);
			if furthestTarget ~= nil and GetUnitToUnitDistance(furthestTarget, bot) > nRadius then
				local tTarget = mutils.GetClosestUnitToLocationFrommAll2(bot, nRadius, bot:GetLocation());
				if mutils.IsValidTarget(tTarget) and tTarget:GetTeam() ~= bot:GetTeam() then
					return BOT_ACTION_DESIRE_LOW, furthestTarget;
				end
			elseif furthestTarget ~= nil and GetUnitToUnitDistance(furthestTarget, bot) <= nRadius then
				local tTarget = mutils.GetClosestUnitToLocationFrommAll2(bot, nRadius, bot:GetLocation());
				if mutils.IsValidTarget(tTarget) and tTarget:GetTeam() ~= bot:GetTeam() then
					return BOT_ACTION_DESIRE_LOW, tTarget;	
				end
			end
		end
	end
	
	-- if mutils.IsInTeamFight(bot, 1300)  and mutils.CanCastOnNonMagicImmune(bot) == true
	-- then
		-- local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		-- local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), 0, nRadius, 0, 0 );
		-- local unitCount = abUtils.CountVulnerableUnit(enemies, locationAoE, nRadius, 2);
		-- if ( unitCount >= 2 ) 
		-- then
			-- return BOT_ACTION_DESIRE_LOW, bot;
		-- end
	-- end
	
	if mutils.IsGoingOnSomeone(bot) and mutils.CanCastOnNonMagicImmune(bot) == true
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) 
		then
			if mutils.IsInRange(target, bot, nRadius) then
				 return BOT_ACTION_DESIRE_LOW, target;
			elseif mutils.IsInRange(target, bot, nRadius) == false and mutils.IsInRange(target, bot, nCastRange) == true then
				local aCreep = bot:GetNearbyLaneCreeps(nRadius, false);
				local eCreep = bot:GetNearbyLaneCreeps(nRadius, true);
				if #aCreep >= 1 or #eCreep >= 1 then
					return BOT_ACTION_DESIRE_LOW, target;
				end
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

function ConsiderE()
	if not mutils.CanBeCast(abilities[3]) or bot:HasModifier("modifier_tiny_tree_grab") == true
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[3]:GetCastRange());
	
	if mutils.IsRetreating(bot) == false and bot:GetHealth() > 0.15*bot:GetMaxHealth() and bot:DistanceFromFountain() > 1000 then
		local trees = bot:GetNearbyTrees(500);
		if #trees > 0 and ( IsLocationVisible(GetTreeLocation(trees[1])) or IsLocationPassable(GetTreeLocation(trees[1])) ) then
			return BOT_ACTION_DESIRE_LOW, trees[1];
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end		

function ConsiderE2()
	if not mutils.CanBeCast(abilities[5]) or bot:HasModifier("modifier_tiny_tree_grab") == false
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[5]:GetCastRange());
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(target, bot, 0.3*nCastRange) == false and mutils.IsInRange(target, bot, nCastRange) == true
			and bot:GetAttackDamage() >= target:GetHealth()
		then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end		

function ConsiderD()
	if not mutils.CanBeCast(abilities[4]) or bot:HasScepter() == false 
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[4]:GetCastRange());
	local nRadius =  abilities[4]:GetSpecialValueInt('tree_grab_radius');
	local nRadius2 =  abilities[4]:GetSpecialValueInt('splash_radius');
	
	if mutils.IsInTeamFight(bot, 1300)  
	then
		local trees = bot:GetNearbyTrees(nRadius);
		if #trees >= 3 then
			local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius2, 0, 0 );
			if ( locationAoE.count >= 2 ) then
				local target = mutils.GetVulnerableUnitNearLoc(true, true, nCastRange, nRadius2, locationAoE.targetloc, bot);
				if target ~= nil then
					return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
				end
			end
		end
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange) == true
		then
			local trees = bot:GetNearbyTrees(nRadius);
			if #trees >= 3 then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end		

function ConsiderR()
	if not mutils.CanBeCast(abilities[4]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[4]:GetCastRange());
	local nCastPoint = abilities[4]:GetCastPoint();
	local manaCost  = abilities[4]:GetManaCost();
	local nRadius   = abilities[4]:GetSpecialValueInt( "jump_range" );
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	if mutils.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) then
			local target = mutils.GetVulnerableUnitNearLoc(true, true, nCastRange, nRadius, locationAoE.targetloc, bot);
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, target;
			end
		end
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange)
		then
			local enemies = target:GetNearbyHeroes( nRadius-200, false, BOT_MODE_NONE );
			local nInvUnit = mutils.CountInvUnits(false, enemies);
			if nInvUnit >= 2 then
				return BOT_ACTION_DESIRE_HIGH, target;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end
	