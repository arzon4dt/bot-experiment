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
				"item_clarity",
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
				"item_ring_of_health",
				"item_void_stone",
				"item_platemail",
				"item_energy_booster",
				"item_recipe_guardian_greaves",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity"
			};

-- Set up Skill build
local SKILL_Q = "elder_titan_echo_stomp";
local SKILL_W = "elder_titan_ancestral_spirit";
local SKILL_E = "elder_titan_natural_order";
local SKILL_R = "elder_titan_earth_splitter";    

local ABILITY1 = "special_bonus_strength_10"
local ABILITY2 = "special_bonus_respawn_reduction_20"
local ABILITY3 = "special_bonus_unique_elder_titan_2"
local ABILITY4 = "special_bonus_hp_275"
local ABILITY5 = "special_bonus_attack_speed_50"
local ABILITY6 = "special_bonus_magic_resistance_12"
local ABILITY7 = "special_bonus_unique_elder_titan"
local ABILITY8 = "special_bonus_armor_15"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_W,    SKILL_E,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_W,    SKILL_Q,    talents[1],
    SKILL_W,    SKILL_R,    SKILL_E,    SKILL_E,    talents[4],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X;