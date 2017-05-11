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
				"item_wind_lace",
				"item_magic_stick",
				"item_circlet",
				"item_boots",
				"item_ring_of_regen",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity",
				"item_ring_of_regen",
				"item_staff_of_wizardry",
				"item_recipe_force_staff",
				"item_circlet",
				"item_mantle",
				"item_recipe_null_talisman",
				"item_circlet",
				"item_mantle",
				"item_recipe_null_talisman",
				"item_helm_of_iron_will",
				"item_recipe_veil_of_discord",
				"item_cloak",
				"item_shadow_amulet",
				"item_void_stone",
				"item_ultimate_orb",
				"item_mystic_staff"
			};

-- Set up Skill build
local SKILL_Q = "keeper_of_the_light_illuminate";
local SKILL_W = "keeper_of_the_light_mana_leak";
local SKILL_E = "keeper_of_the_light_chakra_magic";
local SKILL_R = "keeper_of_the_light_spirit_form";    

local ABILITY1 = "special_bonus_movement_speed_20"
local ABILITY2 = "special_bonus_strength_7"
local ABILITY3 = "special_bonus_respawn_reduction_25"
local ABILITY4 = "special_bonus_exp_boost_20"
local ABILITY5 = "special_bonus_armor_7"
local ABILITY6 = "special_bonus_magic_resistance_10"
local ABILITY7 = "special_bonus_unique_keeper_of_the_light"
local ABILITY8 = "special_bonus_cast_range_400"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_E,    SKILL_W,    SKILL_Q,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_E,    SKILL_E,    talents[2],
    SKILL_E,    SKILL_R,    SKILL_W,    SKILL_W,    talents[3],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X