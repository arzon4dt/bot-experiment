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
				"item_shadow_amulet",
				"item_ring_of_health",
				"item_energy_booster",
				"item_recipe_aether_lens",
				"item_recipe_guardian_greaves",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity",
				"item_wind_lace",
				"item_staff_of_wizardry",
				"item_void_stone",
				"item_recipe_cyclone"
			};

-- Set up Skill build
local SKILL_Q = "disruptor_thunder_strike";
local SKILL_W = "disruptor_glimpse";
local SKILL_E = "disruptor_kinetic_field";
local SKILL_R = "disruptor_static_storm";    

local ABILITY1 = "special_bonus_gold_income_10"
local ABILITY2 = "special_bonus_cast_range_100"
local ABILITY3 = "special_bonus_respawn_reduction_30"
local ABILITY4 = "special_bonus_unique_disruptor_2"
local ABILITY5 = "special_bonus_spell_amplify_10"
local ABILITY6 = "special_bonus_hp_400"
local ABILITY7 = "special_bonus_magic_resistance_30"
local ABILITY8 = "special_bonus_unique_disruptor"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_E,    SKILL_W,    SKILL_Q,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_E,    SKILL_E,    talents[2],
    SKILL_E,    SKILL_R,    SKILL_W,    SKILL_W,    talents[4],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X