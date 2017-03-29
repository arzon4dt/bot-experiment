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
				"item_magic_stick",
				"item_circlet",
				"item_branches",
				"item_branches",
				"item_boots",
				"item_ring_of_regen",
				"item_recipe_headdress",
				"item_chainmail",
				"item_recipe_buckler",
				"item_energy_booster",
				"item_recipe_mekansm",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_cloak",
				"item_shadow_amulet",
				"item_wind_lace",
				"item_staff_of_wizardry",
				"item_void_stone",
				"item_recipe_cyclone",
				"item_recipe_guardian_greaves",
				"item_void_stone",
				"item_ultimate_orb",
				"item_mystic_staff"
			};

-- Set up Skill build
local SKILL_Q = "winter_wyvern_arctic_burn";
local SKILL_W = "winter_wyvern_splinter_blast";
local SKILL_E = "winter_wyvern_cold_embrace";
local SKILL_R = "winter_wyvern_winters_curse";    

local ABILITY1 = "special_bonus_strength_7"
local ABILITY2 = "special_bonus_intelligence_8"
local ABILITY3 = "special_bonus_attack_damage_40"
local ABILITY4 = "special_bonus_movement_speed_20"
local ABILITY5 = "special_bonus_respawn_reduction_35"
local ABILITY6 = "special_bonus_gold_income_20"
local ABILITY7 = "special_bonus_unique_winter_wyvern_2"
local ABILITY8 = "special_bonus_unique_winter_wyvern_1"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_E,    SKILL_W,    SKILL_W,
    SKILL_R,    SKILL_W,    SKILL_E,    SKILL_E,    talents[1],
    SKILL_E,    SKILL_R,    SKILL_Q,    SKILL_Q,    talents[4],
    SKILL_Q,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X