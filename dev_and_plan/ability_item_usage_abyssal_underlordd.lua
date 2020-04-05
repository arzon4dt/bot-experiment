local bot = GetBot();

if bot:IsInvulnerable() or bot:IsHero() == false or bot:IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local mod   = require(GetScriptDirectory() ..  "/botutils")

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end

--[[ Ability Slot
"Ability1"		"abyssal_underlord_firestorm"
"Ability2"		"abyssal_underlord_pit_of_malice"
"Ability3"		"abyssal_underlord_atrophy_aura"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"abyssal_underlord_dark_rift"
"Ability7"		"abyssal_underlord_cancel_dark_rift"
"Ability10"		"special_bonus_unique_underlord_2"
"Ability11"		"special_bonus_movement_speed_30"
"Ability12"		"special_bonus_cast_range_100"
"Ability13"		"special_bonus_unique_underlord_3"
"Ability14"		"special_bonus_attack_speed_70"
"Ability15"		"special_bonus_hp_regen_20"
"Ability16"		"special_bonus_unique_underlord"
"Ability17"		"special_bonus_unique_underlord_4"
]]

--[[ Related Modifiers
modifier_abyssal_underlord_firestorm_thinker
modifier_abyssal_underlord_firestorm_burn
modifier_abyssal_underlord_pit_of_malice_thinker
modifier_abyssal_underlord_pit_of_malice_ensare
modifier_abyssal_underlord_pit_of_malice_buff_placer
modifier_abyssal_underlord_atrophy_aura
modifier_abyssal_underlord_atrophy_aura_effect
modifier_abyssal_underlord_atrophy_aura_hero_buff
modifier_abyssal_underlord_atrophy_aura_creep_buff
modifier_abyssal_underlord_atrophy_aura_dmg_buff_counter
modifier_abyssal_underlord_atrophy_aura_scepter
modifier_abyssal_underlord_dark_rift
]]

local abilities = mod.GetSkills(bot, {0,1,2,5,6});
local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castRDesire = 0;

local function ConsiderQ()
	if mod.CanBeCast(abilities[1]) == false then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange  = mod.GetProperCastRange(bot, abilities[1]:GetCastRange());
	local nCastPoint  = abilities[1]:GetCastPoint();
	local nManaCost   = abilities[1]:GetManaCost();
	local nRadius 	  = abilities[1]:GetSpecialValueInt( "radius" );
	
	if mod.IsRetreating(bot) 
	then
		local target = mod.GetWeakestEnemy(bot, nCastRange);
		if target ~= nil then
			return BOT_ACTION_DESIRE_MODERATE, target:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	if ( mod.IsDefending(bot) or mod.IsPushing(bot) ) and mod.GetDataCount(bot, 'ecreep') >= 3 then
		local locAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius/2, nCastPoint, 0 );
		if ( locAoE.count >= 4  ) then
			return BOT_ACTION_DESIRE_MODERATE, locAoE.targetloc;
		end
	end
	
	if mod.IsInTeamFight(bot, 1300) then
		local locAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0);
		if locAoE.count >= 2 then
			local loc = mod.GetEnemyNearLoc(bot, locAoE.targetloc, nRadius);;
			if loc ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, loc;
			end
		end
	end
	
	if mod.IsGoingAfterSomeone(bot) then
		local target = bot:GetTarget();
		if mod.IsValidHero(target) and mod.CanCastOnNonMagicImmune(target) and mod.IsInCastRange(bot, target, nCastRange) then
			return BOT_ACTION_DESIRE_MODERATE, target:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

local function ConsiderW()
	if mod.CanBeCast(abilities[2]) == false then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange  = mod.GetProperCastRange(bot, abilities[2]:GetCastRange());
	local nCastPoint  = abilities[2]:GetCastPoint();
	local nManaCost   = abilities[2]:GetManaCost();
	local nRadius 	  = abilities[2]:GetSpecialValueInt( "radius" );
	
	if mod.IsRetreating(bot) 
	then
		local target = mod.GetWeakestEnemy(bot, nCastRange);
		if target ~= nil then
			return BOT_ACTION_DESIRE_MODERATE, target:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	if ( mod.IsDefending(bot) or mod.IsPushing(bot) ) and mod.CanSpamSkill() and mod.GetDataCount(bot, 'ecreep') >= 5 then
		local locAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		if ( locAoE.count >= 5 ) then
			return BOT_ACTION_DESIRE_MODERATE, locAoE.targetloc;
		end
	end
	
	if mod.IsInTeamFight(bot, 1300) then
		local locAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0);
		if locAoE.count >= 2 then
			local loc = mod.GetEnemyNearLoc(bot, locAoE.targetloc, nRadius);
			if loc ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, loc;
			end
		end
	end
	
	if mod.IsGoingAfterSomeone(bot) then
		local target = bot:GetTarget();
		if mod.IsValidHero(target) and mod.CanCastOnNonMagicImmune(target) and mod.IsInCastRange(bot, target, nCastRange) then
			return BOT_ACTION_DESIRE_MODERATE, target:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

local function ConsiderR()
	if mod.CanBeCast(abilities[4]) == false then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	if bot:DistanceFromFountain() < 2200 then
		return BOT_ACTION_DESIRE_NONE, nil;
	end	
	
	local nRadius 	  = abilities[2]:GetSpecialValueInt( "radius" );
	
	if mod.IsStuck(bot)
	then
		return BOT_ACTION_DESIRE_MODERATE, mod.GetTeamBase();
	end
	
	if mod.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0) 
	then
		return BOT_ACTION_DESIRE_MODERATE, mod.GetTeamBase();
	end
	
	if mod.IsGoingAfterSomeone(bot) then
		local target = bot:GetTarget();
		if mod.IsValidHero(target) and mod.IsInCastRange(bot, target, 3000) == false then
			local creeps = target:GetNearbyCreeps( 1000, true );
			if #creeps >= 3 then
				return BOT_ACTION_DESIRE_MODERATE, target:GetLocation();
			end	
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function AbilityUsageThink()

	if mod.CantUseAbility(bot) then return end

	castQDesire, castQLoc = ConsiderQ();
	castWDesire, castWLoc = ConsiderW();
	--castRDesire, castRLoc = ConsiderR();
	
	if ( castRDesire > 0 ) 
	then
		bot:Action_UseAbilityOnLocation( abilities[4], castRLoc );
		return;
	end
	
	if ( castQDesire > 0 ) 
	then
		bot:Action_UseAbilityOnLocation( abilities[1], castQLoc );
		return;
	end
	
	if ( castWDesire > 0 ) 
	then
		bot:Action_UseAbilityOnLocation( abilities[2], castWLoc );
		return;
	end
	
end
