X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
--[[ warning if meepo does not have an item other than 
brown boots / power treads at any time he will think he 
is a clone and skill/item decisions will break! ]]
X["items"] = {
				"item_tango",
				"item_circlet",
				"item_slippers",
				"item_recipe_wraith_band",
				"item_boots",
				"item_ring_of_protection",
				"item_sobi_mask",
				"item_boots_of_elves",
				"item_gloves",
				"item_boots_of_elves",
				"item_boots_of_elves",
				"item_ogre_axe",
				"item_quarterstaff",
				"item_sobi_mask",
				"item_robe",
				"item_quarterstaff",
				"item_sobi_mask",
				"item_robe",
				"item_recipe_orchid",
				"item_ogre_axe",
				"item_mithril_hammer",
				"item_recipe_black_king_bar",
				"item_blight_stone",
				"item_mithril_hammer",
				"item_mithril_hammer",
				"item_broadsword",
				"item_blades_of_attack",
				"item_recipe_lesser_crit",
				"item_recipe_bloodthorn",
				"item_demon_edge",
				"item_javelin",
				"item_javelin",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_recipe_hurricane_pike"
			};

-- Set up Skill build
local SKILL_Q = "clinkz_strafe";
local SKILL_W = "clinkz_searing_arrows";
local SKILL_E = "clinkz_wind_walk";
local SKILL_R = "clinkz_death_pact";    


local ABILITY1 = "special_bonus_magic_resistance_10"
local ABILITY2 = "special_bonus_intelligence_10"
local ABILITY3 = "special_bonus_unique_clinkz_1"
local ABILITY4 = "special_bonus_strength_15"
local ABILITY5 = "special_bonus_all_stats_10"
local ABILITY6 = "special_bonus_evasion_20"
local ABILITY7 = "special_bonus_unique_clinkz_2"
local ABILITY8 = "special_bonus_attack_range_125"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_W,    SKILL_E,    SKILL_W,    SKILL_E,    SKILL_W,
    SKILL_R,    SKILL_W,    SKILL_Q,    SKILL_E,    talents[2],
    SKILL_E,    SKILL_R,    SKILL_Q,    SKILL_Q,    talents[4],
    SKILL_Q,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X