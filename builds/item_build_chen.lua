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
				"item_ring_of_health",
				"item_ring_of_regen",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity",
				"item_ring_of_regen",
				"item_branches",
				"item_recipe_headdress",
				"item_recipe_pipe",
				"item_recipe_guardian_greaves",
				"item_void_stone",
				"item_ultimate_orb",
				"item_mystic_staff"
			};

-- Set up Skill build
local SKILL_Q = "chen_penitence";
local SKILL_W = "chen_test_of_faith";
local SKILL_E = "chen_holy_persuasion";
local SKILL_R = "chen_hand_of_god";    

local ABILITY1 = "special_bonus_cast_range_125"
local ABILITY2 = "special_bonus_movement_speed_25"
local ABILITY3 = "special_bonus_unique_chen_3"
local ABILITY4 = "special_bonus_hp_250"
local ABILITY5 = "special_bonus_respawn_reduction_40"
local ABILITY6 = "special_bonus_gold_income_15"
local ABILITY7 = "special_bonus_unique_chen_2"
local ABILITY8 = "special_bonus_unique_chen_1"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_E,    SKILL_W,    SKILL_Q,    SKILL_E,    SKILL_E,
    SKILL_R,    SKILL_E,    SKILL_W,    SKILL_W,    talents[2],
    SKILL_W,    SKILL_R,    SKILL_Q,    SKILL_Q,    talents[3],
    SKILL_Q,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};
--[[X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_W,    SKILL_Q,    SKILL_W,
    SKILL_R,    SKILL_W,    SKILL_Q,    SKILL_Q,    ABILITY1,
    SKILL_E,    SKILL_R,    SKILL_E,    SKILL_E,    ABILITY3,
    SKILL_E,    "-1",       SKILL_R,    "-1",   	ABILITY6,
    "-1",   	"-1",   	"-1",       "-1",       ABILITY7
};]]--

return X