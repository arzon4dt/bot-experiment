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
				"item_boots",
				"item_blades_of_attack",
				"item_blades_of_attack",
				"item_claymore",
				"item_shadow_amulet",
				"item_blade_of_alacrity",
				"item_boots_of_elves",
				"item_recipe_yasha",
				"item_ogre_axe",
				"item_belt_of_strength",
				"item_recipe_sange",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity",
				"item_blight_stone",
				"item_mithril_hammer",
				"item_mithril_hammer",
				"item_ultimate_orb",
				"item_recipe_silver_edge",
				"item_demon_edge",
				"item_javelin",
				"item_javelin"
			};

-- Set up Skill build
local SKILL_Q = "tusk_ice_shards";
local SKILL_W = "tusk_snowball";
local SKILL_E = "tusk_frozen_sigil";
local SKILL_R = "tusk_walrus_punch";    


local ABILITY1 = "special_bonus_attack_damage_35"
local ABILITY2 = "special_bonus_exp_boost_40"
local ABILITY3 = "special_bonus_gold_income_15"
local ABILITY4 = "special_bonus_unique_tusk_2"
local ABILITY5 = "special_bonus_magic_resistance_12"
local ABILITY6 = "special_bonus_armor_6"
local ABILITY7 = "special_bonus_unique_tusk"
local ABILITY8 = "special_bonus_hp_700"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_W,    SKILL_Q,    SKILL_W,    SKILL_Q,    SKILL_W,
    SKILL_R,    SKILL_W,    SKILL_Q,    SKILL_Q,    talents[2],
    SKILL_E,    SKILL_R,    SKILL_E,    SKILL_E,    talents[4],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};


return X