if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

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

local bot = GetBot();

local abilities = {};

local castQDesire = 0;
local castWDesire = 0;
local castRDesire = 0;
local castR2Desire = 0;

function AbilityUsageThink()
	
	if #abilities == 0 then abilities = mutils.InitiateAbilities(bot, {0,1,5,6}) end
	
	if mutils.CantUseAbility(bot) then return end
	
	castQDesire, QLoc = ConsiderQ();
	castWDesire       = ConsiderW();
	castRDesire       = ConsiderR();
	castR2Desire      = ConsiderR2();
	
	if castRDesire > 0 then
		bot:Action_UseAbility(abilities[3]);		
		return
	end
	
	if castQDesire > 0 then
		-- print(tostring(QLoc))
		bot:Action_UseAbilityOnLocation(abilities[1], QLoc);		
		return
	end
	
	if castWDesire > 0 then
		bot:Action_UseAbility(abilities[2]);		
		return
	end
	
	if castR2Desire > 0 then
		bot:Action_UseAbility(abilities[4]);		
		return
	end
	
end

function ConsiderQ()
	if not mutils.CanBeCast(abilities[1]) or bot:HasModifier("modifier_pangolier_gyroshell") or bot:HasModifier('modifier_pangolier_swashbuckle_stunned') 
	   or bot:IsRooted()	
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[1]:GetCastRange());
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost  = abilities[1]:GetManaCost();
	local nRadius   = abilities[1]:GetSpecialValueInt( "start_radius" );
	
	if mutils.IsStuck(bot)
	then
		local loc = mutils.GetEscapeLoc();
		return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation( loc, nCastRange );
	end
	
	if mutils.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( bot:WasRecentlyDamagedByAnyHero(2.0) or bot:WasRecentlyDamagedByTower(2.0) or #tableNearbyEnemyHeroes > 1 )
		then
			local loc = mutils.GetEscapeLoc();
		    return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation( loc, nCastRange );
		end	
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if mutils.IsValidTarget(npcTarget) and mutils.CanCastOnMagicImmune(npcTarget) and mutils.IsInRange(npcTarget, bot, nCastRange) 
		then
			local tableNearbyEnemies = npcTarget:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
			local tableNearbyAllies = npcTarget:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
			if #tableNearbyEnemies <= #tableNearbyAllies then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE, nil;
end


function ConsiderW()
	if not mutils.CanBeCast(abilities[2]) then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = abilities[2]:GetSpecialValueInt("radius");
	local nCastPoint = abilities[2]:GetCastPoint();
	local manaCost  = abilities[2]:GetManaCost();
	
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if #tableNearbyEnemyHeroes > 0 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nRadius)
		then
			local enemies = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
			if #enemies >= 2 then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderR()
	if not mutils.CanBeCast(abilities[3]) then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if mutils.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( bot:WasRecentlyDamagedByAnyHero(2.0) or bot:WasRecentlyDamagedByTower(2.0) or #tableNearbyEnemyHeroes > 1 )
		then
		    return BOT_ACTION_DESIRE_HIGH;
		end	
	end
	
	if mutils.IsInTeamFight(bot, 1300)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local nInvUnit = mutils.CountInvUnits(false, tableNearbyEnemyHeroes);
		if nInvUnit >= 2 then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, 600)
		then
			local enemies = target:GetNearbyHeroes(600, false, BOT_MODE_NONE);
			if #enemies >= 3 then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderR2()
	return BOT_ACTION_DESIRE_NONE;
end