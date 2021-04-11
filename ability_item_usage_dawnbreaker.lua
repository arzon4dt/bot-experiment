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
local castRDesire = 0;

local lastCheck = -90;
local castWTime = -90;

function AbilityUsageThink()
	
	if #abilities == 0 then abilities = mutils.InitiateAbilities(bot, {0,1,3,5}) end
	
	if mutils.CantUseAbility(bot) then return end
	
	castQDesire, targetQ = ConsiderQ();
	castWDesire, targetW = ConsiderW();
	castEDesire, targetE  = ConsiderE();
	castRDesire, targetR = ConsiderR();
	
	if castWDesire > 0 then
		castWTime = DotaTime();
		bot:Action_UseAbilityOnLocation(abilities[2], targetW);		
		return
	end
	
	if castEDesire > 0 then
		bot:Action_UseAbility( abilities[3] );
		return
	end
	
	if castRDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[4], targetR);		
		return
	end
	
	if castQDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[1], targetQ);		
		return
	end
	
	
end

function IsCastingStarBreaker()
	return bot:HasModifier('modifier_dawnbreaker_fire_wreath_caster') or bot:HasModifier('modifier_dawnbreaker_fire_wreath_attack_bonus') or bot:HasModifier('modifier_dawnbreaker_fire_wreath_slow'); 
end

function ConsiderQ()
	if not mutils.CanBeCast(abilities[1]) or IsCastingStarBreaker() then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nRadius   = abilities[1]:GetSpecialValueInt( "swipe_radius" );
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[1]:GetCastRange());
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost  = abilities[1]:GetManaCost();
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local enemies = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
		if #enemies > 0 then
			local loc = mutils.GetEscapeLoc();
			return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation( loc, nCastRange );
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
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function ConsiderW()
	if not mutils.CanBeCast(abilities[2]) or IsCastingStarBreaker() then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[2]:GetSpecialValueInt('range'));
	local nCastPoint = abilities[2]:GetCastPoint();
	local manaCost  = abilities[2]:GetManaCost();
	local nRadius   = abilities[2]:GetSpecialValueInt( "flare_radius" );
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local enemies = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
		if #enemies > 0 then
			local loc = mutils.GetEscapeLoc();
			return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation( loc, nCastRange );
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
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

function ConsiderE()
	if not mutils.CanBeCast(abilities[3]) or IsCastingStarBreaker() or DotaTime() < castWTime + 1
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		return BOT_ACTION_DESIRE_HIGH, nil;
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		return BOT_ACTION_DESIRE_HIGH, nil;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end		

function ConsiderR()
	if not mutils.CanBeCast(abilities[4]) or IsCastingStarBreaker() then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, 1600);
	local nCastPoint = abilities[4]:GetCastPoint();
	local manaCost  = abilities[4]:GetManaCost();
	local nRadius   = abilities[4]:GetSpecialValueInt( "radius" );
	
	local numPlayer =  GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer
	do
		local Player = GetTeamMember(i);
		if Player:IsAlive() and Player ~= bot
		then
			local tableNearbyEnemyHeroes = Player:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
			local nInvUnit = mutils.CountInvUnits(true, tableNearbyEnemyHeroes);
			if nInvUnit >= 2 then
				return BOT_ACTION_DESIRE_MODERATE, Player:GetLocation();
			end
		end
	end
	
	if mutils.IsInTeamFight(bot, 1600)
	then
		local allies = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
		for i=1, #allies do
			if allies[i] ~= bot and mutils.CanCastOnNonMagicImmune(allies[i]) and mutils.IsInRange(allies[i], bot, 800) == false 
			then
				local tableNearbyEnemyHeroes = allies[i]:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
				local nInvUnit = mutils.CountInvUnits(true, tableNearbyEnemyHeroes);
				if nInvUnit >= 2 then
					return BOT_ACTION_DESIRE_ABSOLUTE, allies[i]:GetLocation();
				end
			end
		end
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and not mutils.IsInRange(target, bot, 1600)
		then
			local allies = target:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
			for i=1, #allies do
				if allies[i] ~= bot and mutils.CanCastOnNonMagicImmune(allies[i])
				then
					local tableNearbyEnemyHeroes = allies[i]:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
					local nInvUnit = mutils.CountInvUnits(true, tableNearbyEnemyHeroes);
					if nInvUnit >= 2 then
						return BOT_ACTION_DESIRE_ABSOLUTE, allies[i]:GetLocation();
					end
				end
			end
			
			local numPlayer =  GetTeamPlayers(GetTeam());
			for i = 1, #numPlayer
			do
				local Player = GetTeamMember(i);
				if Player:IsAlive() and Player ~= bot
				then
					local tableNearbyEnemyHeroes = Player:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
					local nInvUnit = mutils.CountInvUnits(true, tableNearbyEnemyHeroes);
					if nInvUnit >= 2 then
						return BOT_ACTION_DESIRE_MODERATE, Player:GetLocation();
					end
				end
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end
	