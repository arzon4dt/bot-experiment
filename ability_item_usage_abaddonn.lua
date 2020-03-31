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
function ItemUsageThink()
	ability_item_usage_generic.ItemUsageThink();
end

--[[ Ability Slot
"Ability1"		"abaddon_death_coil"
"Ability2"		"abaddon_aphotic_shield"
"Ability3"		"abaddon_frostmourne"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"abaddon_borrowed_time"
"Ability10"		"special_bonus_movement_speed_25"
"Ability11"		"special_bonus_exp_boost_20"
"Ability12"		"special_bonus_armor_6"
"Ability13"		"special_bonus_unique_abaddon_2"
"Ability14"		"special_bonus_cooldown_reduction_15"
"Ability15"		"special_bonus_attack_damage_90"
"Ability16"		"special_bonus_unique_abaddon"
"Ability17"		"special_bonus_unique_abaddon_3"
]]--

--[[ Related Modifiers
modifier_abaddon_aphotic_shield
modifier_abaddon_frostmourne
modifier_abaddon_frostmourne_debuff
modifier_abaddon_frostmourne_buff
modifier_abaddon_borrowed_time
modifier_abaddon_borrowed_time_passive
modifier_abaddon_borrowed_time_damage_redirect
]]

local abilities = mod.GetSkills(bot, {0,1,2,5});
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
	local nDamage     = abilities[1]:GetSpecialValueInt('target_damage');
	local nSelfDamage = abilities[1]:GetSpecialValueInt('self_damage');
	
	if ( mod.IsRetreating(bot) and bot:GetHealth() <= nSelfDamage and bot:HasModifier('modifier_abaddon_aphotic_shield') == false ) 
	   or bot:HasModifier("modifier_abaddon_borrowed_time")
	then
		local target = mod.GetWeakestEnemy(bot, nCastRange);
		if target ~= nil then
			return BOT_ACTION_DESIRE_MODERATE, target;
		end
	end
	
	if mod.IsInTeamFight(bot, 1300) then
		local target = mod.GetWeakestAlly(bot, nCastRange);
		if target ~= nil and target:GetHealth() <= 0.5*target:GetMaxHealth() then
			return BOT_ACTION_DESIRE_MODERATE, target;
		end
	end
	
	if mod.IsGoingAfterSomeone(bot) then
		local target = bot:GetTarget();
		if mod.IsValidHero(target) and mod.CanCastOnNonMagicImmune(target) and mod.IsInCastRange(bot, target, nCastRange) then
			return BOT_ACTION_DESIRE_MODERATE, target;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

local function ConsiderW()
	if mod.CanBeCast(abilities[2]) == false then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange  = mod.GetProperCastRange(bot, abilities[2]:GetCastRange());
	local nManaCost   = abilities[2]:GetManaCost();
	
	if mod.IsRetreating(bot) and bot:HasModifier('modifier_abaddon_aphotic_shield') == false 
	   and bot:HasModifier("modifier_abaddon_borrowed_time") == false
	then
		return BOT_ACTION_DESIRE_MODERATE, bot;
	end
	
	if mod.IsInTeamFight(bot, 1300) then
		local target = mod.GetDisabledAlly(bot, nCastRange);
		if target ~= nil then
			return BOT_ACTION_DESIRE_MODERATE, target;
		end
		target = mod.GetWeakestAlly(bot, nCastRange);
		if target ~= nil and target:GetHealth() <= 0.5*target:GetMaxHealth() then
			return BOT_ACTION_DESIRE_MODERATE, target;
		end
	end
	
	if mod.IsGoingAfterSomeone(bot) then
		local target = bot:GetTarget();
		if mod.IsValidHero(target) and mod.IsInCastRange(bot, target, 1200) then
			if mod.GetDataCount(bot, 'ally') == 1 and mod.GetDataCount(bot, 'enemy') == 1 then
				return BOT_ACTION_DESIRE_MODERATE, bot;
			else
				local closest = mod.GetClosestAlly(bot, target, nCastRange);
				if closest ~= nil then
					return BOT_ACTION_DESIRE_MODERATE, closest;
				end	
			end	
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function AbilityUsageThink()

	if mod.CantUseAbility(bot) then return end
	
	castQDesire, castQTarget = ConsiderQ();
	castWDesire, castWTarget = ConsiderW();

	if ( castQDesire > 0 ) 
	then
		bot:Action_UseAbilityOnEntity( abilities[1], castQTarget );
		return;
	end

	if ( castWDesire > 0 ) 
	then
		bot:Action_UseAbilityOnEntity( abilities[2], castWTarget );
		return;
	end
	
end


