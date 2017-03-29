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
				"item_clarity",
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
				"item_ring_of_health",
				"item_void_stone",
				"item_platemail",
				"item_energy_booster",
				"item_recipe_guardian_greaves",
				"item_ring_of_regen",
				"item_branches",
				"item_recipe_headdress",
				"item_recipe_pipe",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity"
			};

-- Set up Skill build
local SKILL_Q = "undying_decay";
local SKILL_W = "undying_soul_rip";
local SKILL_E = "undying_tombstone";
local SKILL_R = "undying_flesh_golem";    

local ABILITY1 = "special_bonus_gold_income_15"
local ABILITY2 = "special_bonus_respawn_reduction_30"
local ABILITY3 = "special_bonus_hp_300"
local ABILITY4 = "special_bonus_exp_boost_35"
local ABILITY5 = "special_bonus_movement_speed_30"
local ABILITY6 = "special_bonus_unique_undying"
local ABILITY7 = "special_bonus_unique_undying_2"
local ABILITY8 = "special_bonus_armor_15"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_E,    SKILL_E,    SKILL_E,
    SKILL_R,    SKILL_E,    SKILL_W,    SKILL_W,    talents[2],
    SKILL_W,    SKILL_R,    SKILL_Q,    SKILL_Q,    talents[3],
    SKILL_Q,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X