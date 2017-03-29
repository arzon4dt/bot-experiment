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
				"item_platemail",
				"item_mystic_staff",
				"item_recipe_shivas_guard",
				"item_point_booster",
				"item_vitality_booster",
				"item_energy_booster",
				"item_mystic_staff"
			};

-- Set up Skill build
local SKILL_Q = "necrolyte_death_pulse";
local SKILL_W = "necrolyte_sadist";
local SKILL_E = "necrolyte_heartstopper_aura";
local SKILL_R = "necrolyte_reapers_scythe";    

local ABILITY1 = "special_bonus_strength_6"
local ABILITY2 = "special_bonus_attack_damage_40"
local ABILITY3 = "special_bonus_movement_speed_20"
local ABILITY4 = "special_bonus_all_stats_6"
local ABILITY5 = "special_bonus_magic_resistance_10"
local ABILITY6 = "special_bonus_spell_amplify_5"
local ABILITY7 = "special_bonus_unique_necrophos"
local ABILITY8 = "special_bonus_hp_400"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_E,    SKILL_Q,    SKILL_W,    SKILL_Q,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_W,    SKILL_W,    talents[1],
    SKILL_W,    SKILL_R,    SKILL_E,    SKILL_E,    talents[3],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X