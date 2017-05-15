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
				"item_magic_stick",
				"item_circlet",
				"item_blades_of_attack",
				"item_boots",
				"item_blades_of_attack",
				"item_claymore",
				"item_shadow_amulet",
				"item_broadsword",
				"item_blades_of_attack",
				"item_recipe_lesser_crit",
				"item_demon_edge",
				"item_recipe_greater_crit",
				"item_blink",
				"item_broadsword",
				"item_blades_of_attack",
				"item_recipe_lesser_crit",
				"item_demon_edge",
				"item_recipe_greater_crit",
				"item_ultimate_orb",
				"item_recipe_silver_edge",
				"item_ogre_axe",
				"item_mithril_hammer",
				"item_recipe_black_king_bar"
			};

-- Set up Skill build
local SKILL_Q = "kunkka_torrent";
local SKILL_W = "kunkka_tidebringer";
local SKILL_E = "kunkka_x_marks_the_spot";
local SKILL_R = "kunkka_ghostship";    


local ABILITY1 = "special_bonus_unique_kunkka_2"
local ABILITY2 = "special_bonus_attack_damage_25"
local ABILITY3 = "special_bonus_movement_speed_20"
local ABILITY4 = "special_bonus_hp_regen_15"
local ABILITY5 = "special_bonus_gold_income_20"
local ABILITY6 = "special_bonus_hp_300"
local ABILITY7 = "special_bonus_unique_kunkka"
local ABILITY8 = "special_bonus_magic_resistance_35"

--use -1 for levels that shouldn't level a skill
--[[X["skills"] = {
    SKILL_W,    SKILL_Q,    SKILL_W,    SKILL_Q,    SKILL_W,
    SKILL_R,    SKILL_W,    SKILL_Q,    SKILL_Q,    ABILITY2,
    SKILL_E,    SKILL_R,    SKILL_E,    SKILL_E,    ABILITY4,
    SKILL_E,    "-1",       SKILL_R,    "-1",   	ABILITY5,
    "-1",   	"-1",   	"-1",       "-1",       ABILITY7
};]]--
X["skills"] = {
    SKILL_W,    SKILL_Q,    SKILL_E,    SKILL_E,    SKILL_E,
    SKILL_R,    SKILL_E,    SKILL_Q,    SKILL_Q,    talents[1],
    SKILL_Q,    SKILL_R,    SKILL_W,    SKILL_W,    talents[3],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X