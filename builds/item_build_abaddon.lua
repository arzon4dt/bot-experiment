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
				--"item_cloak",
				--"item_shadow_amulet",
				"item_ring_of_health",
				"item_void_stone",
				"item_platemail",
				"item_energy_booster",
				"item_recipe_guardian_greaves",
				"item_ring_of_health",
				"item_energy_booster",
				"item_recipe_aether_lens",
				"item_platemail",
				"item_mystic_staff",
				"item_recipe_shivas_guard"
			};

-- Set up Skill build
local SKILL_Q = "abaddon_death_coil";
local SKILL_W = "abaddon_aphotic_shield";
local SKILL_E = "abaddon_frostmourne";
local SKILL_R = "abaddon_borrowed_time";   


local ABILITY1 = "special_bonus_exp_boost_20"
local ABILITY2 = "special_bonus_attack_damage_25"
local ABILITY3 = "special_bonus_armor_5"
local ABILITY4 = "special_bonus_mp_200"
local ABILITY5 = "special_bonus_cooldown_reduction_15"
local ABILITY6 = "special_bonus_movement_speed_25"
local ABILITY7 = "special_bonus_unique_abaddon"
local ABILITY8 = "special_bonus_strength_25"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_Q,    SKILL_W,    SKILL_W,
    SKILL_R,    SKILL_Q,    SKILL_W,    SKILL_Q,    talents[2],
    SKILL_E,    SKILL_R,    SKILL_E,    SKILL_E,    talents[3],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X