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
				"item_boots",
				"item_energy_booster",
				"item_branches",
				"item_ring_of_regen",
				"item_recipe_headdress",
				"item_branches",
				"item_chainmail",
				"item_recipe_buckler",
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
				"item_point_booster",
				"item_vitality_booster",
				"item_energy_booster",
				"item_mystic_staff"
			};

-- Set up Skill build
local SKILL_Q = "oracle_fortunes_end";
local SKILL_W = "oracle_fates_edict";
local SKILL_E = "oracle_purifying_flames";
local SKILL_R = "oracle_false_promise";    

local ABILITY1 = "special_bonus_exp_boost_20"
local ABILITY2 = "special_bonus_respawn_reduction_20"
local ABILITY3 = "special_bonus_gold_income_10"
local ABILITY4 = "special_bonus_hp_200"
local ABILITY5 = "special_bonus_intelligence_20"
local ABILITY6 = "special_bonus_movement_speed_25"
local ABILITY7 = "special_bonus_unique_oracle"
local ABILITY8 = "special_bonus_cast_range_250"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_E,    SKILL_E,    SKILL_W,    SKILL_E,
    SKILL_R,    SKILL_E,    SKILL_Q,    SKILL_Q,    talents[1],
    SKILL_Q,    SKILL_R,    SKILL_W,    SKILL_W,    talents[4],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X