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
				"item_boots",
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_boots_of_elves",
				"item_gloves",
				"item_blade_of_alacrity",
				"item_boots_of_elves",
				"item_recipe_yasha",
				"item_gloves",
				"item_mithril_hammer",
				"item_recipe_maelstrom",
				"item_ultimate_orb",
				"item_recipe_manta",
				"item_ogre_axe",
				"item_mithril_hammer",
				"item_recipe_black_king_bar",
				"item_hyperstone",
				"item_recipe_mjollnir",
				"item_broadsword",
				"item_blades_of_attack",
				"item_recipe_lesser_crit",
				"item_demon_edge",
				"item_recipe_greater_crit",
				"item_eagle",
				"item_quarterstaff",
				"item_talisman_of_evasion"
			};

-- Set up Skill build
local SKILL_Q = "faceless_void_time_walk";
local SKILL_W = "faceless_void_time_dilation";
local SKILL_E = "faceless_void_time_lock";
local SKILL_R = "faceless_void_chronosphere";    


local ABILITY1 = "special_bonus_strength_8"
local ABILITY2 = "special_bonus_attack_speed_15"
local ABILITY3 = "special_bonus_attack_damage_25"
local ABILITY4 = "special_bonus_armor_7"
local ABILITY5 = "special_bonus_gold_income_20"
local ABILITY6 = "special_bonus_hp_300"
local ABILITY7 = "special_bonus_unique_faceless_void"
local ABILITY8 = "special_bonus_evasion_20"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_E,    SKILL_Q,    SKILL_W,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_E,    SKILL_E,    talents[1],
    SKILL_E,    SKILL_R,    SKILL_W,    SKILL_W,    talents[4],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X