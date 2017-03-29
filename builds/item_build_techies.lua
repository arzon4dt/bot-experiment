X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
--[[ warning if meepo does not have an item other than 
brown boots / power treads at any time he will think he 
is a clone and skill/item decisions will break! ]]
X["items"] = {
				"item_tango",
				"item_sobi_mask",
				"item_clarity",
				"item_enchanted_mango",
				"item_ring_of_regen",
				"item_recipe_soul_ring",
				"item_boots",
				"item_energy_booster",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_wind_lace",
				"item_void_stone",
				"item_staff_of_wizardry",
				"item_recipe_cyclone",
				"item_energy_booster",
				"item_point_booster",
				"item_vitality_booster",
				"item_recipe_bloodstone",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity",
				"item_void_stone",
				"item_ultimate_orb",
				"item_mystic_staff"
			};

-- Set up Skill build
local SKILL_Q = "techies_land_mines";
local SKILL_W = "techies_stasis_trap";
local SKILL_E = "techies_suicide";
local SKILL_R = "techies_remote_mines";   


local ABILITY1 = "special_bonus_mp_regen_2"
local ABILITY2 = "special_bonus_movement_speed_20"
local ABILITY3 = "special_bonus_cast_range_200"
local ABILITY4 = "special_bonus_exp_boost_30"
local ABILITY5 = "special_bonus_respawn_reduction_60"
local ABILITY6 = "special_bonus_gold_income_20"
local ABILITY7 = "special_bonus_unique_techies"
local ABILITY8 = "special_bonus_cooldown_reduction_20"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_E,    SKILL_Q,    SKILL_E,    SKILL_E,
    SKILL_R,    SKILL_Q,    SKILL_E,    SKILL_Q,    talents[2],
    SKILL_W,    SKILL_R,    SKILL_W,    SKILL_W,    talents[3],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X