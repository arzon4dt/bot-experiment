X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
--[[ warning if meepo does not have an item other than 
brown boots / power treads at any time he will think he 
is a clone and skill/item decisions will break! ]]
X["items"] = {
				"item_blades_of_attack",
				"item_tango",
				"item_boots",
				"item_blades_of_attack",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity",
				"item_wind_lace",
				"item_staff_of_wizardry",
				"item_void_stone",
				"item_recipe_cyclone",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_blink",
				"item_void_stone",
				"item_ultimate_orb",
				"item_mystic_staff"
			};

-- Set up Skill build
local SKILL_Q = "invoker_quas";
local SKILL_W = "invoker_wex";
local SKILL_E = "invoker_exort";   

local ABILITY1 = "special_bonus_hp_125"
local ABILITY2 = "special_bonus_attack_damage_15"
local ABILITY3 = "special_bonus_exp_boost_30"
local ABILITY4 = "special_bonus_unique_invoker_1"
local ABILITY5 = "special_bonus_attack_speed_35"
local ABILITY6 = "special_bonus_all_stats_7"
local ABILITY7 = "special_bonus_unique_invoker_3"
local ABILITY8 = "special_bonus_unique_invoker_2"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_E,    SKILL_Q,    SKILL_E,    SKILL_Q,    SKILL_E,
    SKILL_Q,    SKILL_E,    SKILL_Q,    SKILL_W,    talents[2],
    SKILL_E,    SKILL_E,    SKILL_E,    SKILL_W,    talents[4],
    SKILL_W,    SKILL_W,    SKILL_W,    SKILL_W,   	talents[5],
    SKILL_W,   	SKILL_Q,   	SKILL_Q,    SKILL_Q,    talents[8]
};

return X