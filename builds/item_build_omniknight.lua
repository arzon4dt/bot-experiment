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
				"item_energy_booster",
				"item_ring_of_regen",
				"item_recipe_headdress",
				"item_chainmail",
				"item_recipe_buckler",
				"item_recipe_mekansm",
				"item_cloak",
				"item_shadow_amulet",
				"item_cloak",
				"item_ring_of_health",
				"item_ring_of_regen",
				"item_ring_of_regen",
				"item_branches",
				"item_recipe_headdress",
				"item_recipe_pipe",
				"item_recipe_guardian_greaves",
				"item_ring_of_health",
				"item_void_stone",
				"item_platemail",
				"item_energy_booster",
				"item_platemail",
				"item_mystic_staff",
				"item_recipe_shivas_guard"
			};

-- Set up Skill build
local SKILL_Q = "omniknight_purification";
local SKILL_W = "omniknight_repel";
local SKILL_E = "omniknight_degen_aura";
local SKILL_R = "omniknight_guardian_angel";    

local ABILITY1 = "special_bonus_exp_boost_20"
local ABILITY2 = "special_bonus_gold_income_10"
local ABILITY3 = "special_bonus_strength_8"
local ABILITY4 = "special_bonus_cast_range_75"
local ABILITY5 = "special_bonus_mp_regen_6"
local ABILITY6 = "special_bonus_attack_damage_100"
local ABILITY7 = "special_bonus_unique_omniknight_2"
local ABILITY8 = "special_bonus_unique_omniknight_1"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_Q,    SKILL_E,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_W,    SKILL_W,    talents[2],
    SKILL_W,    SKILL_R,    SKILL_E,    SKILL_E,    talents[4],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X