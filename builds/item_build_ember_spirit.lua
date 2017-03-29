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
local SKILL_Q = "ember_spirit_searing_chains";
local SKILL_W = "ember_spirit_sleight_of_fist";
local SKILL_E = "ember_spirit_flame_guard";
local SKILL_R = "ember_spirit_fire_remnant";    

local ABILITY1 = "special_bonus_attack_damage_25"
local ABILITY2 = "special_bonus_spell_amplify_10"
local ABILITY3 = "special_bonus_all_stats_6"
local ABILITY4 = "special_bonus_movement_speed_20"
local ABILITY5 = "special_bonus_armor_10"
local ABILITY6 = "special_bonus_unique_ember_spirit_1"
local ABILITY7 = "special_bonus_unique_ember_spirit_2"
local ABILITY8 = "special_bonus_cooldown_reduction_20"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_E,    SKILL_E,    SKILL_Q,    SKILL_E,
    SKILL_R,    SKILL_E,    SKILL_Q,    SKILL_Q,    talents[1],
    SKILL_W,    SKILL_R,    SKILL_W,    SKILL_W,    talents[4],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X