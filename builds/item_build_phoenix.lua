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
				"item_wind_lace",
				"item_magic_stick",
				"item_circlet",
				"item_boots",
				"item_ring_of_regen",
				"item_circlet",
				"item_mantle",
				"item_recipe_null_talisman",
				"item_circlet",
				"item_mantle",
				"item_recipe_null_talisman",
				"item_helm_of_iron_will",
				"item_recipe_veil_of_discord",
				"item_cloak",
				"item_shadow_amulet",
				"item_staff_of_wizardry",
				"item_staff_of_wizardry",
				"item_vitality_booster",
				"item_platemail",
				"item_mystic_staff",
				"item_recipe_shivas_guard",
				"item_point_booster",
				"item_vitality_booster",
				"item_energy_booster",
				"item_mystic_staff"
			};

-- Set up Skill build
local SKILL_Q = "phoenix_icarus_dive";
local SKILL_W = "phoenix_fire_spirits";
local SKILL_E = "phoenix_sun_ray";
local SKILL_R = "phoenix_supernova";    

local ABILITY1 = "special_bonus_hp_125"
local ABILITY2 = "special_bonus_respawn_reduction_20"
local ABILITY3 = "special_bonus_gold_income_20"
local ABILITY4 = "special_bonus_strength_12"
local ABILITY5 = "special_bonus_spell_amplify_8"
local ABILITY6 = "special_bonus_armor_10"
local ABILITY7 = "special_bonus_unique_phoenix_2"
local ABILITY8 = "special_bonus_unique_phoenix_1"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_E,    SKILL_W,    SKILL_W,
    SKILL_R,    SKILL_W,    SKILL_Q,    SKILL_Q,    talents[1],
    SKILL_Q,    SKILL_R,    SKILL_E,    SKILL_E,    talents[4],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X