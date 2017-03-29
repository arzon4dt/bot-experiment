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
				"item_energy_booster",
				"item_ring_of_regen",
				"item_recipe_headdress",
				"item_chainmail",
				"item_recipe_buckler",
				"item_recipe_mekansm",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_cloak",
				"item_ring_of_health",
				"item_ring_of_regen",
				"item_circlet",
				"item_mantle",
				"item_recipe_null_talisman",
				"item_circlet",
				"item_mantle",
				"item_recipe_null_talisman",
				"item_helm_of_iron_will",
				"item_recipe_veil_of_discord",
				"item_recipe_guardian_greaves",
				"item_ring_of_regen",
				"item_branches",
				"item_recipe_headdress",
				"item_recipe_pipe",
				"item_platemail",
				"item_mystic_staff",
				"item_recipe_shivas_guard"
			};

-- Set up Skill build
local SKILL_Q = "abyssal_underlord_firestorm";
local SKILL_W = "abyssal_underlord_pit_of_malice";
local SKILL_E = "abyssal_underlord_atrophy_aura";
local SKILL_R = "abyssal_underlord_dark_rift";    

local ABILITY1 = "special_bonus_mp_regen_2"
local ABILITY2 = "special_bonus_armor_4"
local ABILITY3 = "special_bonus_spell_amplify_10"
local ABILITY4 = "special_bonus_movement_speed_35"
local ABILITY5 = "special_bonus_cast_range_125"
local ABILITY6 = "special_bonus_attack_speed_60"
local ABILITY7 = "special_bonus_unique_abyssal_underlord"
local ABILITY8 = "special_bonus_hp_regen_50"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_W,    SKILL_E,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_W,    SKILL_Q,    talents[2],
    SKILL_W,    SKILL_R,    SKILL_E,    SKILL_E,    talents[4],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X;