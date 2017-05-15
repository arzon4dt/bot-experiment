X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
--[[ warning if meepo does not have an item other than 
brown boots / power treads at any time he will think he 
is a clone and skill/item decisions will break! ]]
X["items"] = {
				"item_flask",
				"item_tango",
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
				"item_blink",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity"
			};

-- Set up Skill build
local SKILL_Q = "shadow_shaman_ether_shock";
local SKILL_W = "shadow_shaman_voodoo";
local SKILL_E = "shadow_shaman_shackles";
local SKILL_R = "shadow_shaman_mass_serpent_ward";    

local ABILITY1 = "special_bonus_hp_175"
local ABILITY2 = "special_bonus_movement_speed_20"
local ABILITY3 = "special_bonus_cast_range_100"
local ABILITY4 = "special_bonus_exp_boost_30"
local ABILITY5 = "special_bonus_respawn_reduction_30"
local ABILITY6 = "special_bonus_magic_resistance_20"
local ABILITY7 = "special_bonus_unique_shadow_shaman_1"
local ABILITY8 = "special_bonus_unique_shadow_shaman_2"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_E,    SKILL_Q,    SKILL_W,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_W,    SKILL_W,    talents[1],
    SKILL_W,    SKILL_R,    SKILL_E,    SKILL_E,    talents[4],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X