X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
--[[ warning if meepo does not have an item other than 
brown boots / power treads at any time he will think he 
is a clone and skill/item decisions will break! ]]
X["items"] = {
				"item_tango",
				"item_stout_shield",
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_boots",
				"item_energy_booster",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_cloak",
				"item_shadow_amulet",
				"item_ring_of_health",
				"item_energy_booster",
				"item_recipe_aether_lens",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity",
				"item_ring_of_health",
				"item_void_stone",
				"item_platemail",
				"item_energy_booster"
			};

-- Set up Skill build
local SKILL_Q = "ogre_magi_fireblast";
local SKILL_W = "ogre_magi_ignite";
local SKILL_E = "ogre_magi_bloodlust";
local SKILL_R = "ogre_magi_multicast";    

local ABILITY1 = "special_bonus_gold_income_10"
local ABILITY2 = "special_bonus_cast_range_100"
local ABILITY3 = "special_bonus_attack_damage_50"
local ABILITY4 = "special_bonus_magic_resistance_8"
local ABILITY5 = "special_bonus_hp_250"
local ABILITY6 = "special_bonus_movement_speed_25"
local ABILITY7 = "special_bonus_spell_amplify_15"
local ABILITY8 = "special_bonus_unique_ogre_magi"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_W,    SKILL_Q,    SKILL_W,    SKILL_Q,    SKILL_E,
    SKILL_R,    SKILL_Q,    SKILL_W,    SKILL_Q,    talents[1],
    SKILL_W,    SKILL_R,    SKILL_E,    SKILL_E,    talents[4],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X