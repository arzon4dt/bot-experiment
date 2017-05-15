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
				"item_stout_shield",
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
				"item_cloak",
				"item_ring_of_health",
				"item_ring_of_regen",
				"item_branches",
				"item_ring_of_regen",
				"item_recipe_headdress",
				"item_recipe_pipe",
				"item_blink",
				"item_ring_of_health",
				"item_void_stone",
				"item_platemail",
				"item_energy_booster",
				"item_recipe_guardian_greaves",
				"item_platemail",
				"item_mystic_staff",
				"item_recipe_shivas_guard"
			};

-- Set up Skill build
local SKILL_Q = "dark_seer_vacuum";
local SKILL_W = "dark_seer_ion_shell";
local SKILL_E = "dark_seer_surge";
local SKILL_R = "dark_seer_wall_of_replica";    

local ABILITY1 = "special_bonus_cast_range_100"
local ABILITY2 = "special_bonus_evasion_12"
local ABILITY3 = "special_bonus_hp_regen_14"
local ABILITY4 = "special_bonus_attack_damage_120"
local ABILITY5 = "special_bonus_unique_dark_seer_2"
local ABILITY6 = "special_bonus_cooldown_reduction_10"
local ABILITY7 = "special_bonus_unique_dark_seer"
local ABILITY8 = "special_bonus_strength_25"


X["skills"] = {
    SKILL_W,    SKILL_E,    SKILL_W,    SKILL_E,    SKILL_W,
    SKILL_R,    SKILL_W,    SKILL_Q,    SKILL_Q,    talents[2],
    SKILL_Q,    SKILL_R,    SKILL_Q,    SKILL_E,    talents[4],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X