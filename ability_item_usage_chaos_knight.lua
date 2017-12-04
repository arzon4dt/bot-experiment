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

--[[
"Ability1"		"chaos_knight_chaos_bolt"
"Ability2"		"chaos_knight_reality_rift"
"Ability3"		"chaos_knight_chaos_strike"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"chaos_knight_phantasm"
"Ability10"		"special_bonus_all_stats_5"
"Ability11"		"special_bonus_movement_speed_20"
"Ability12"		"special_bonus_strength_15"
"Ability13"		"special_bonus_cooldown_reduction_12"
"Ability14"		"special_bonus_gold_income_25"
"Ability15"		"special_bonus_unique_chaos_knight"
"Ability16"		"special_bonus_unique_chaos_knight_2"
"Ability17"		"special_bonus_unique_chaos_knight_3"
]]--

--[[
modifier_chaos_knight_reality_rift
modifier_chaos_knight_chaos_strike
modifier_chaos_knight_chaos_strike_debuff
modifier_chaos_knight_phantasm
]]--

local abilities = mutils.InitiateAbilities(bot, {0,1,2,5});

print(tostring(bot:GetPlayerID())..":"..tostring(abilities[1]));

local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castRDesire = 0;

local function ConsiderQ()
	if  mutils.CanBeCast(abilities[1]) == false then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[1]:GetCastRange());
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost   = abilities[1]:GetManaCost();

	local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);	
	if #enemies > 0 then
		for i=1, #enemies do
			if mutils.CanCastOnNonMagicImmune(enemies[i]) and enemies[i]:IsChanneling()
			   and enemies[i]:HasModifier("modifier_teleporting") == false 
			then
				return BOT_ACTION_DESIRE_LOW, enemies[i]:GetLocation();
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN and mutils.CanSpamSpell(bot, manaCost) then
		local target =  bot:GetAttackTarget();
		if target ~= nil then
			return BOT_ACTION_DESIRE_LOW, target;
		end
	end
	
	if mutils.IsRetreating(bot) then
		if #enemies > 0 then
			local target = nil;
			local maxDmg = 0;	
			for i=1, #enemies do	
				local estDmg = enemies[i]:GetEstimatedDamageToTarget(true, bot, 2.0, DAMAGE_TYPE_ALL);
				if mutils.CanCastOnNonMagicImmune(enemies[i]) 
				   and estDmg >= maxDmg 
				   and enemies[i]:GetAttackTarget() ~= nil
				then
					target = enemies[i];
					maxAD  = estDmg;
				end
			end
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, target;
			end
		end
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange) 
		   and mutils.IsDisabled(true, target) == false
		then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

local function ConsiderW()
	if  mutils.CanBeCast(abilities[2]) == false then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[2]:GetCastRange());
	local nCastPoint = abilities[2]:GetCastPoint();
	local manaCost   = abilities[2]:GetManaCost();

	if mutils.IsRetreating(bot) then
		local loc = mutils.GetEscapeLoc();
		local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		local creeps  = bot:GetNearbyLaneCreeps(nCastRange, true);
		local target = nil;
		local minDist = 100000;
		if #enemies > 0 then
			for i=1, #enemies do
				local dist = GetUnitToLocationDistance(enemies[i], loc);
				if mutils.CanCastOnNonMagicImmune(enemies[i]) and dist <= minDist then
					target = enemies[1];
					minDist = dist;
				end
			end
		end
		if #creeps > 0 then
			for i=1, #creeps do
				local dist = GetUnitToLocationDistance(creeps[i], loc);
				if mutils.CanCastOnNonMagicImmune(creeps[i]) and dist <= minDist then
					target = creeps[1];
					minDist = dist;
				end
			end
		end
		if target ~= nil and GetUnitToUnitDistance(bot, target) >= 0.5*nCastRange and minDist < GetUnitToLocationDistance(bot, loc) then
			return BOT_ACTION_DESIRE_NONE, target;
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN and mutils.CanSpamSpell(bot, manaCost) then
		local target =  bot:GetAttackTarget();
		if target ~= nil then
			return BOT_ACTION_DESIRE_LOW, target;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) 
		   and mutils.IsInRange(target, bot, bot:GetAttackRange()) == false and mutils.IsInRange(target, bot, nCastRange) 
		then
			local allies  = target:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
			local enemies = target:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE);
			if #allies >= #enemies then
				return BOT_ACTION_DESIRE_HIGH, target;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

local function ConsiderR()
	if  mutils.CanBeCast(abilities[4]) == false then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if mutils.IsInTeamFight(bot, 1200) and bot:GetActiveMode() ~= BOT_MODE_RETREAT then
		local enemies = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
		if #enemies >= 2 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if ( mutils.IsPushing(bot) )
	then
		local target = bot:GetAttackTarget();
		local towers = bot:GetNearbyTowers(1000, true);
		if target ~= nil and target:IsBuilding() and #towers > 0 then
			local allies = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
			local creeps = bot:GetNearbyLaneCreeps(1000, false);
			if #allies >= 2 and #creeps >= 5 then
				return BOT_ACTION_DESIRE_HIGH;
			end	
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end	

function AbilityUsageThink()
	
	if mutils.CantUseAbility(bot) then return end
	
	castQDesire, qTarget = ConsiderQ();
	castWDesire, wTarget = ConsiderW();
	castRDesire	         = ConsiderR();
	
	if castRDesire > 0 then
		bot:Action_UseAbility(abilities[4]);		
		return
	end
	
	if castQDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[1], qTarget);		
		return
	end
	
	if castWDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[2], wTarget);	
		return
	end
	
end