X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
--[[ warning if meepo does not have an item other than 
brown boots / power treads at any time he will think he 
is a clone and skill/item decisions will break! ]]
X["items"] = {
				"item_tango",
				"item_branches",
				"item_branches",
				"item_bottle",
				"item_magic_stick",
				"item_circlet",
				"item_boots",
				"item_gloves",
				"item_belt_of_strength",
				"item_circlet",
				"item_mantle",
				"item_recipe_null_talisman",
				"item_circlet",
				"item_mantle",
				"item_recipe_null_talisman",
				"item_helm_of_iron_will",
				"item_recipe_veil_of_discord",
				"item_quarterstaff",
				"item_sobi_mask",
				"item_robe",
				"item_quarterstaff",
				"item_sobi_mask",
				"item_robe",
				"item_recipe_orchid",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity",
				"item_point_booster",
				"item_vitality_booster",
				"item_energy_booster",
				"item_mystic_staff",
				"item_broadsword",
				"item_blades_of_attack",
				"item_recipe_lesser_crit",
				"item_recipe_bloodthorn",
				"item_platemail",
				"item_mystic_staff",
				"item_recipe_shivas_guard"
			};

-- Set up Skill build
local SKILL_Q = "queenofpain_shadow_strike";
local SKILL_W = "queenofpain_blink";
local SKILL_E = "queenofpain_scream_of_pain";
local SKILL_R = "queenofpain_sonic_wave";    

local ABILITY1 = "special_bonus_strength_9"
local ABILITY2 = "special_bonus_attack_damage_25"
local ABILITY3 = "special_bonus_gold_income_15"
local ABILITY4 = "special_bonus_cooldown_reduction_12"
local ABILITY5 = "special_bonus_hp_300"
local ABILITY6 = "special_bonus_attack_range_100"
local ABILITY7 = "special_bonus_spell_lifesteal_70"
local ABILITY8 = "special_bonus_unique_queenofpain"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_E,    SKILL_E,    SKILL_E,
    SKILL_R,    SKILL_E,    SKILL_Q,    SKILL_W,    talents[1],
    SKILL_Q,    SKILL_R,    SKILL_W,    SKILL_Q,    talents[3],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X