X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
--[[ warning if meepo does not have an item other than 
brown boots / power treads at any time he will think he 
is a clone and skill/item decisions will break! ]]
X["items"] = {
				"item_tango",
				"item_stout_shield",
				"item_ring_of_protection",
				"item_sobi_mask",
				"item_boots",
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_blades_of_attack",
				"item_blades_of_attack",
				"item_branches",
				"item_ring_of_regen",
				"item_recipe_headdress",
				"item_lifesteal",
				"item_quarterstaff",
				"item_sobi_mask",
				"item_robe",
				"item_quarterstaff",
				"item_sobi_mask",
				"item_robe",
				"item_recipe_orchid",
				"item_mithril_hammer",
				"item_ogre_axe",
				"item_recipe_black_king_bar",
				"item_hyperstone",
				"item_platemail",
				"item_chainmail",
				"item_recipe_assault",
				"item_broadsword",
				"item_blades_of_attack",
				"item_recipe_lesser_crit",
				"item_recipe_bloodthorn",
				"item_quarterstaff",
				"item_talisman_of_evasion",
				"item_eagle"
			};

-- Set up Skill build
local SKILL_Q = "broodmother_spawn_spiderlings";
local SKILL_W = "broodmother_spin_web";
local SKILL_E = "broodmother_incapacitating_bite";
local SKILL_R = "broodmother_insatiable_hunger";    

local ABILITY1 = "special_bonus_exp_boost_25"
local ABILITY2 = "special_bonus_unique_broodmother_3"
local ABILITY3 = "special_bonus_hp_325"
local ABILITY4 = "special_bonus_cooldown_reduction_20"
local ABILITY5 = "special_bonus_attack_speed_70"
local ABILITY6 = "special_bonus_unique_broodmother_4"
local ABILITY7 = "special_bonus_unique_broodmother_2"
local ABILITY8 = "special_bonus_unique_broodmother_1"


X["skills"] = {
    SKILL_W,    SKILL_Q,    SKILL_Q,    SKILL_W,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_W,    SKILL_W,    talents[2],
    SKILL_E,    SKILL_R,    SKILL_E,    SKILL_E,    talents[3],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X