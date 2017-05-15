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
				"item_clarity",
				"item_magic_stick",
				"item_circlet",
				"item_boots",
				"item_energy_booster",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity",
				"item_branches",
				"item_ring_of_regen",
				"item_recipe_headdress",
				"item_branches",
				"item_chainmail",
				"item_recipe_buckler",
				"item_recipe_mekansm",
				"item_recipe_guardian_greaves",
				"item_platemail",
				"item_mystic_staff",
				"item_recipe_shivas_guard",
				"item_ring_of_health",
				"item_void_stone",
				"item_ring_of_health",
				"item_void_stone",
				"item_recipe_refresher",
				"item_void_stone",
				"item_ultimate_orb",
				"item_mystic_staff"
			};

-- Set up Skill build
local SKILL_Q = "warlock_fatal_bonds";
local SKILL_W = "warlock_shadow_word";
local SKILL_E = "warlock_upheaval";
local SKILL_R = "warlock_rain_of_chaos";    


local ABILITY1 = "special_bonus_all_stats_6"
local ABILITY2 = "special_bonus_exp_boost_20"
local ABILITY3 = "special_bonus_unique_warlock_3"
local ABILITY4 = "special_bonus_cast_range_150"
local ABILITY5 = "special_bonus_respawn_reduction_30"
local ABILITY6 = "special_bonus_hp_350"
local ABILITY7 = "special_bonus_unique_warlock_2"
local ABILITY8 = "special_bonus_unique_warlock_1"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_W,    SKILL_Q,    SKILL_W,    SKILL_E,    SKILL_W,
    SKILL_R,    SKILL_W,    SKILL_Q,    SKILL_Q,    talents[1],
    SKILL_Q,    SKILL_R,    SKILL_E,    SKILL_E,    talents[3],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X