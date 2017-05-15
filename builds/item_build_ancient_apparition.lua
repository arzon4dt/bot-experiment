X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
--[[ warning if meepo does not have an item other than 
brown boots / power treads at any time he will think he 
is a clone and skill/item decisions will break! ]]
X["items"] = {
				"item_tango",
				"item_flask",
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
				"item_circlet",
				"item_mantle",
				"item_recipe_null_talisman",
				"item_circlet",
				"item_mantle",
				"item_recipe_null_talisman",
				"item_helm_of_iron_will",
				"item_recipe_veil_of_discord",
				"item_ring_of_regen",
				"item_staff_of_wizardry",
				"item_recipe_force_staff",
				"item_cloak",
				"item_shadow_amulet",
				"item_void_stone",
				"item_ultimate_orb",
				"item_mystic_staff"
			};

-- Set up Skill build
local SKILL_Q = "ancient_apparition_cold_feet";
local SKILL_W = "ancient_apparition_ice_vortex";
local SKILL_E = "ancient_apparition_chilling_touch";
local SKILL_R = "ancient_apparition_ice_blast";    

local ABILITY1 = "special_bonus_spell_amplify_8"
local ABILITY2 = "special_bonus_gold_income_10"
local ABILITY3 = "special_bonus_hp_regen_30"
local ABILITY4 = "special_bonus_unique_ancient_apparition"
local ABILITY5 = "special_bonus_respawn_reduction_35"
local ABILITY6 = "special_bonus_movement_speed_35"
local ABILITY7 = "special_bonus_unique_ancient_apparition_2"
local ABILITY8 = "special_bonus_unique_ancient_apparition_3"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_E,    SKILL_Q,    SKILL_W,    SKILL_Q,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_W,    SKILL_W,    talents[1],
    SKILL_W,    SKILL_R,    SKILL_E,    SKILL_E,    talents[4],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X